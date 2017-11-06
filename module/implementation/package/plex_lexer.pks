CREATE OR REPLACE PACKAGE plex_lexer AS

    ----------------------------------------------------------------------------
    -- Exposed LexemeTokenizer methods
    ----------------------------------------------------------------------------  
    FUNCTION getIndex RETURN PLS_INTEGER;
    FUNCTION getLine RETURN PLS_INTEGER;
    FUNCTION getLineIndex RETURN PLS_INTEGER;

    -- initialize from dictionary would require lexer to have excesive and unnecessary privileges
    -- therefore there is initialize method that takes source lines as parameter
    -- and the caller is responsible for obtaining them
    PROCEDURE initialize(p_source_lines IN plex.source_lines_type);

    FUNCTION currentItem RETURN VARCHAR2;

    PROCEDURE consume;

    FUNCTION eof RETURN BOOLEAN;

    FUNCTION peek(p_lookahead PLS_INTEGER) RETURN VARCHAR2;

    PROCEDURE takeSnapshot;

    PROCEDURE rollbackSnapshot;

    PROCEDURE commitSnapshot;

    FUNCTION isSpecialCharacter(p_character IN VARCHAR2) RETURN BOOLEAN;

    ----------------------------------------------------------------------------  
    -- Lexer methods
    ----------------------------------------------------------------------------  
    FUNCTION nextToken RETURN plex_token;

    FUNCTION tokens RETURN plex_tokens;

END plex_lexer;
/
