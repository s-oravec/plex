CREATE OR REPLACE PACKAGE BODY plex_lexer AS

    g_index               PLS_INTEGER;
    g_line                PLS_INTEGER;
    g_lineIndex           PLS_INTEGER;
    g_snapshotIndexes     plex_integer_stack;
    g_snapshotLines       plex_integer_stack;
    g_snapshotLineIndexes plex_integer_stack;
    g_source              CLOB;
    g_sourceTextLines     plex.source_lines_type;

    Type typ_tableOfTokens IS TABLE OF plex.token_type;
    g_specialCharacterTokens typ_tableOfTokens;
    g_keywordTokens          typ_tableOfTokens;

    g_matchers plex_matchers;

    ----------------------------------------------------------------------------
    FUNCTION getIndex RETURN PLS_INTEGER IS
    BEGIN
        RETURN g_index;
    END;

    ----------------------------------------------------------------------------
    FUNCTION getLine RETURN PLS_INTEGER IS
    BEGIN
        RETURN g_line;
    END;

    ----------------------------------------------------------------------------
    FUNCTION getLineIndex RETURN PLS_INTEGER IS
    BEGIN
        RETURN g_lineIndex;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE initializeMatchers IS
        PROCEDURE appendMatcher(p_matcher plex_matcher) IS
        BEGIN
            g_matchers.extend();
            g_matchers(g_matchers.count) := p_matcher;
        END;
    BEGIN
        g_matchers := plex_matchers();
        -- order of append matchers into g_metchers is significant - they are evaluated in that order
        --
        -- add matcher for single line comment
        appendMatcher(NEW plex_matchSingleLineComment());
        --
        -- add matcher for multi line comment
        appendMatcher(NEW plex_matchMultiLineComment());
        --
        -- add matcher for matching labels
        appendMatcher(NEW plex_matchLabel());
        --
        -- add special characters matchers    
        FOR idx IN 1 .. g_specialCharacterTokens.count LOOP
            appendMatcher(NEW plex_matchKeyword(g_specialCharacterTokens(idx), g_specialCharacterTokens(idx)));
        END LOOP;
        --
        -- add keyword matchers
        FOR idx IN 1 .. g_keywordTokens.count LOOP
            appendMatcher(NEW plex_matchKeyword(g_keywordTokens(idx), g_keywordTokens(idx), allowAsSubstring => 'N'));
        END LOOP;
        --
        -- add whitespace matcher
        appendMatcher(NEW plex_matchWhitespace());
        --
        -- add matcher for matching string literals
        appendMatcher(NEW plex_matchTextLiteral());
        --
        -- add matcher for matching number literals
        appendMatcher(NEW plex_matchNumberLiteral());
        --
        -- add matcher for matching words - junk actually - variables, unspecified keywords
        appendMatcher(NEW plex_matchWord());
        --
    END;

    ----------------------------------------------------------------------------
    PROCEDURE initialize(p_source_lines IN plex.source_lines_type) IS
    BEGIN
        -- set indexes (we index from 1 in PLSQL)
        g_index     := 1;
        g_line      := 1;
        g_lineIndex := 1;
        -- init snapshot global stacks
        g_snapshotIndexes     := plex_integer_stack();
        g_snapshotLines       := plex_integer_stack();
        g_snapshotLineIndexes := plex_integer_stack();
        --
        g_sourceTextLines := p_source_lines;
        -- concat lines into source clob
        g_source          := '';
        FOR lineIdx IN 1 .. g_sourceTextLines.count LOOP
            g_source := g_source || g_sourceTextLines(lineIdx);
        END LOOP;
        --
        initializeMatchers;
    END;

    ----------------------------------------------------------------------------
    FUNCTION eof(p_lookahead PLS_INTEGER) RETURN BOOLEAN IS
    BEGIN
        IF g_source IS NULL OR g_index + p_lookahead > length(g_source) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION eof RETURN BOOLEAN IS
    BEGIN
        RETURN eof(0);
    END;

    ----------------------------------------------------------------------------
    FUNCTION peek(p_lookahead PLS_INTEGER) RETURN VARCHAR2 IS
        l_result VARCHAR2(1);
    BEGIN
        IF eof(p_lookahead) THEN
            RETURN NULL;
        ELSE
            l_result := substr(g_source, g_index + p_lookahead, 1);
            RETURN l_result;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION currentItem RETURN VARCHAR2 IS
    BEGIN
        IF (eof(0)) THEN
            RETURN NULL;
        ELSE
            RETURN substr(g_source, g_index, 1);
        END IF;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE consume IS
    BEGIN
        g_index := g_index + 1;
        -- increase line as index is already beyond count of chars on line
        -- (= g_lineIndex is on chr(10) that we used to separate lines in g_source clob)
        IF length(g_sourceTextLines(g_line)) < g_lineIndex THEN
            -- switch to next line
            g_line      := g_line + 1;
            g_lineIndex := 1;
        ELSE
            g_lineIndex := g_lineIndex + 1;
        END IF;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE takeSnapshot IS
    BEGIN
        g_snapshotIndexes.push(g_index);
        g_snapshotLines.push(g_line);
        g_snapshotLineIndexes.push(g_lineIndex);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE rollbackSnapshot IS
    BEGIN
        g_index     := g_snapshotIndexes.pop();
        g_line      := g_snapshotLines.pop();
        g_lineIndex := g_snapshotLineIndexes.pop();
    END;

    ----------------------------------------------------------------------------
    PROCEDURE commitSnapshot IS
    BEGIN
        g_snapshotIndexes.pop();
        g_snapshotLines.pop();
        g_snapshotLineIndexes.pop();
    END;

    ----------------------------------------------------------------------------
    FUNCTION isSpecialCharacter(p_character IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        -- plex.tk_Dollar, - not special as it can be part of variableName
        -- plex.tk_Hash, - not special as it can be part of variableName
        -- plex.tk_Underscore  - not special as it can be part of variableName
        RETURN p_character IN(plex.tk_Asterix,
                              plex.tk_Colon,
                              plex.tk_Comma,
                              plex.tk_Dot,
                              plex.tk_Dollar,
                              plex.tk_Equals,
                              plex.tk_ExclamationMark,
                              plex.tk_GreaterThan,
                              plex.tk_LessThan,
                              plex.tk_LParenth,
                              plex.tk_MinusChar,
                              plex.tk_Percent,
                              plex.tk_PipeChar,
                              plex.tk_PlusChar,
                              plex.tk_Quote,
                              plex.tk_RParenth,
                              plex.tk_Semicolon,
                              plex.tk_Slash
                              );
    END;

    ----------------------------------------------------------------------------
    FUNCTION nextTokenImpl RETURN plex_token IS
        l_result plex_token;
    BEGIN
        IF eof THEN
            l_result := NEW plex_token(plex.tk_EOF);
        ELSE
            FOR matcherIdx IN 1 .. g_matchers.count LOOP
                l_result := g_matchers(matcherIdx).isMatch();
                EXIT WHEN l_result IS NOT NULL;
            END LOOP;
        END IF;
        RETURN l_result;
    END;

    ----------------------------------------------------------------------------
    FUNCTION nextToken RETURN plex_token IS
        l_result plex_token;
    BEGIN
        l_result := nextTokenImpl();
        WHILE l_result IS NOT NULL AND l_result.tokenType != plex.tk_EOF LOOP
            -- TODO: make this strip of whitespace/comments optional using parameter
            IF l_result.tokenType NOT IN (plex.tk_WhiteSpace, plex.tk_SingleLineComment, plex.tk_MultilineComment) THEN
                RETURN l_result;
            END IF;
            l_result := nextTokenImpl;
        END LOOP;
        IF l_result IS NULL THEN
            raise_application_error(-20000,
                                    'Unknown token at ' || g_line || ':' || g_lineIndex || ' "' || substr(g_source, g_index, 10) || ' ..."');
        ELSE
            RETURN l_result;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION tokens RETURN plex_tokens IS
        l_result plex_tokens;
    BEGIN
        l_result := plex_tokens();
        LOOP
            l_result.extend;
            l_result(l_result.count) := plex_lexer.nextToken;
            EXIT WHEN l_result(l_result.count).tokenType = plex.tk_EOF;
        END LOOP;
        RETURN l_result;
    END;

BEGIN
    -- order is significant
    -- Assign has to be before Colon, as Colon is its prefix
    g_specialCharacterTokens := typ_tableOfTokens(
        plex.tk_Assign, plex.tk_Asterix, plex.tk_Colon, plex.tk_Comma, plex.tk_Dot, plex.tk_Dollar, plex.tk_Equals, plex.tk_ExclamationMark,
        plex.tk_GreaterThan, plex.tk_LessThan, plex.tk_LParenth, plex.tk_MinusChar, plex.tk_Percent, plex.tk_PipeChar, plex.tk_PlusChar,
        plex.tk_Quote, plex.tk_RParenth, plex.tk_Semicolon, plex.tk_Slash
    );

    g_keywordTokens := typ_tableOfTokens(
        plex.tk_ALL, plex.tk_ALTER, plex.tk_AND, plex.tk_ANY, plex.tk_AS, plex.tk_ASC, plex.tk_AT, plex.tk_BEGIN, plex.tk_BETWEEN, plex.tk_BY,
        plex.tk_CASE, plex.tk_CHECK, plex.tk_CLUSTERS, plex.tk_CLUSTER, plex.tk_COLAUTH, plex.tk_COLUMNS, plex.tk_COMPRESS,
        plex.tk_CONNECT, plex.tk_CRASH, plex.tk_CREATE, plex.tk_CURSOR, plex.tk_DECLARE, plex.tk_DEFAULT, plex.tk_DESC,
        plex.tk_DISTINCT, plex.tk_DROP, plex.tk_ELSE, plex.tk_END, plex.tk_EXCEPTION, plex.tk_EXCLUSIVE, plex.tk_FETCH, plex.tk_FOR,
        plex.tk_FROM, plex.tk_FUNCTION, plex.tk_GOTO, plex.tk_GRANT, plex.tk_GROUP, plex.tk_HAVING, plex.tk_IDENTIFIED, plex.tk_IF,
        plex.tk_IN, plex.tk_INDEX, plex.tk_INDEXES, plex.tk_INSERT, plex.tk_INTERSECT, plex.tk_INTO, plex.tk_IS, plex.tk_LIKE,
        plex.tk_LOCK,
        --plex.tk_MINUS,
         plex.tk_MODE, plex.tk_NOCOMPRESS, plex.tk_NOT, plex.tk_NOWAIT, plex.tk_NULL, plex.tk_OF, plex.tk_ON,
        plex.tk_OPTION, plex.tk_OR, plex.tk_ORDER, plex.tk_OVERLAPS, plex.tk_PROCEDURE, plex.tk_PUBLIC, plex.tk_RESOURCE,
        plex.tk_REVOKE, plex.tk_SELECT, plex.tk_SHARE, plex.tk_SIZE, plex.tk_SQL, plex.tk_START, plex.tk_SUBTYPE, plex.tk_TABAUTH,
        plex.tk_TABLE, plex.tk_THEN, plex.tk_TO, plex.tk_TYPE, plex.tk_UNION, plex.tk_UNIQUE, plex.tk_UPDATE, plex.tk_VALUES,
        plex.tk_VIEW, plex.tk_VIEWS, plex.tk_WHEN, plex.tk_WHERE, plex.tk_WITH
    );

END plex_lexer;
/
