CREATE OR REPLACE PACKAGE plex_lexer AS

    -- keywords
    SUBTYPE TokenType IS VARCHAR2(30);

    -- special characters

    -- order is significant
    -- assign has to be before colon as colon is its prefix
    tk_Asterix         CONSTANT TokenType := '*';
    tk_Assign          CONSTANT TokenType := ':=';
    tk_Colon           CONSTANT TokenType := ':';
    tk_Comma           CONSTANT TokenType := ',';
    tk_Dollar          CONSTANT TokenType := '$';
    tk_Dot             CONSTANT TokenType := '.';
    tk_Equals          CONSTANT TokenType := '=';
    tk_ExclamationMark CONSTANT TokenType := '!';
    tk_GreaterThan     CONSTANT TokenType := '>';
    tk_Hash            CONSTANT TokenType := '#';
    tk_LessThan        CONSTANT TokenType := '<';
    tk_LParenth        CONSTANT TokenType := '(';
    tk_Minus           CONSTANT TokenType := '-';
    tk_Percent         CONSTANT TokenType := '%';
    tk_Pipe            CONSTANT TokenType := '|';
    tk_Plus            CONSTANT TokenType := '+';
    tk_Quote           CONSTANT TokenType := '"';
    tk_RParenth        CONSTANT TokenType := ')';
    tk_Semicolon       CONSTANT TokenType := ';';
    tk_Slash           CONSTANT TokenType := '/';
    tk_Underscore      CONSTANT TokenType := '_';

    -- Reserved words
    kw_ALL        CONSTANT TokenType := 'ALL';
    kw_ALTER      CONSTANT TokenType := 'ALTER';
    kw_AND        CONSTANT TokenType := 'AND';
    kw_ANY        CONSTANT TokenType := 'ANY';
    kw_AS         CONSTANT TokenType := 'AS';
    kw_ASC        CONSTANT TokenType := 'ASC';
    kw_AT         CONSTANT TokenType := 'AT';
    kw_BEGIN      CONSTANT TokenType := 'BEGIN';
    kw_BETWEEN    CONSTANT TokenType := 'BETWEEN';
    kw_BY         CONSTANT TokenType := 'BY';
    kw_CASE       CONSTANT TokenType := 'CASE';
    kw_CLUSTER    CONSTANT TokenType := 'CLUSTER';
    kw_CLUSTERS   CONSTANT TokenType := 'CLUSTERS';
    kw_COLAUTH    CONSTANT TokenType := 'COLAUTH';
    kw_COLUMNS    CONSTANT TokenType := 'COLUMNS';
    kw_COMPRESS   CONSTANT TokenType := 'COMPRESS';
    kw_CONNECT    CONSTANT TokenType := 'CONNECT';
    kw_CRASH      CONSTANT TokenType := 'CRASH';
    kw_CREATE     CONSTANT TokenType := 'CREATE';
    kw_CURSOR     CONSTANT TokenType := 'CURSOR';
    kw_DECLARE    CONSTANT TokenType := 'DECLARE';
    kw_DEFAULT    CONSTANT TokenType := 'DEFAULT';
    kw_DESC       CONSTANT TokenType := 'DESC';
    kw_DISTINCT   CONSTANT TokenType := 'DISTINCT';
    kw_DROP       CONSTANT TokenType := 'DROP';
    kw_ELSE       CONSTANT TokenType := 'ELSE';
    kw_END        CONSTANT TokenType := 'END';
    kw_EXCEPTION  CONSTANT TokenType := 'EXCEPTION';
    kw_EXCLUSIVE  CONSTANT TokenType := 'EXCLUSIVE';
    kw_FETCH      CONSTANT TokenType := 'FETCH';
    kw_FOR        CONSTANT TokenType := 'FOR';
    kw_FROM       CONSTANT TokenType := 'FROM';
    kw_FUNCTION   CONSTANT TokenType := 'FUNCTION';
    kw_GOTO       CONSTANT TokenType := 'GOTO';
    kw_GRANT      CONSTANT TokenType := 'GRANT';
    kw_GROUP      CONSTANT TokenType := 'GROUP';
    kw_HAVING     CONSTANT TokenType := 'HAVING';
    kw_CHECK      CONSTANT TokenType := 'CHECK';
    kw_IDENTIFIED CONSTANT TokenType := 'IDENTIFIED';
    kw_IF         CONSTANT TokenType := 'IF';
    kw_IN         CONSTANT TokenType := 'IN';
    kw_INDEX      CONSTANT TokenType := 'INDEX';
    kw_INDEXES    CONSTANT TokenType := 'INDEXES';
    kw_INSERT     CONSTANT TokenType := 'INSERT';
    kw_INTERSECT  CONSTANT TokenType := 'INTERSECT';
    kw_INTO       CONSTANT TokenType := 'INTO';
    kw_IS         CONSTANT TokenType := 'IS';
    kw_LIKE       CONSTANT TokenType := 'LIKE';
    kw_LOCK       CONSTANT TokenType := 'LOCK';
    kw_MINUS      CONSTANT TokenType := 'MINUS';
    kw_MODE       CONSTANT TokenType := 'MODE';
    kw_NOCOMPRESS CONSTANT TokenType := 'NOCOMPRESS';
    kw_NOT        CONSTANT TokenType := 'NOT';
    kw_NOWAIT     CONSTANT TokenType := 'NOWAIT';
    kw_NULL       CONSTANT TokenType := 'NULL';
    kw_OF         CONSTANT TokenType := 'OF';
    kw_ON         CONSTANT TokenType := 'ON';
    kw_OPTION     CONSTANT TokenType := 'OPTION';
    kw_OR         CONSTANT TokenType := 'OR';
    kw_ORDER      CONSTANT TokenType := 'ORDER';
    kw_OVERLAPS   CONSTANT TokenType := 'OVERLAPS';
    kw_PROCEDURE  CONSTANT TokenType := 'PROCEDURE';
    kw_PUBLIC     CONSTANT TokenType := 'PUBLIC';
    kw_RESOURCE   CONSTANT TokenType := 'RESOURCE';
    kw_REVOKE     CONSTANT TokenType := 'REVOKE';
    kw_SELECT     CONSTANT TokenType := 'SELECT';
    kw_SHARE      CONSTANT TokenType := 'SHARE';
    kw_SIZE       CONSTANT TokenType := 'SIZE';
    kw_SQL        CONSTANT TokenType := 'SQL';
    kw_START      CONSTANT TokenType := 'START';
    kw_SUBTYPE    CONSTANT TokenType := 'SUBTYPE';
    kw_TABAUTH    CONSTANT TokenType := 'TABAUTH';
    kw_TABLE      CONSTANT TokenType := 'TABLE';
    kw_THEN       CONSTANT TokenType := 'THEN';
    kw_TO         CONSTANT TokenType := 'TO';
    kw_TYPE       CONSTANT TokenType := 'TYPE';
    kw_UNION      CONSTANT TokenType := 'UNION';
    kw_UNIQUE     CONSTANT TokenType := 'UNIQUE';
    kw_UPDATE     CONSTANT TokenType := 'UPDATE';
    kw_VALUES     CONSTANT TokenType := 'VALUES';
    kw_VIEW       CONSTANT TokenType := 'VIEW';
    kw_VIEWS      CONSTANT TokenType := 'VIEWS';
    kw_WHEN       CONSTANT TokenType := 'WHEN';
    kw_WHERE      CONSTANT TokenType := 'WHERE';
    kw_WITH       CONSTANT TokenType := 'WITH';

    -- reserved words
    rw_BODY     CONSTANT TokenType := 'BODY';
    rw_CLOSE    CONSTANT TokenType := 'CLOSE';
    rw_CONSTANT CONSTANT TokenType := 'CONSTANT';
    rw_CONTINUE CONSTANT TokenType := 'CONTINUE';
    rw_ELSIF    CONSTANT TokenType := 'ELSIF';
    rw_EXECUTE  CONSTANT TokenType := 'EXECUTE';
    rw_EXIT     CONSTANT TokenType := 'EXIT';
    rw_LOOP     CONSTANT TokenType := 'LOOP';
    rw_FORALL   CONSTANT TokenType := 'FORALL';
    rw_MERGE    CONSTANT TokenType := 'MERGE';
    rw_OPEN     CONSTANT TokenType := 'OPEN';
    rw_PACKAGE  CONSTANT TokenType := 'PACKAGE';
    rw_PIPE     CONSTANT TokenType := 'PIPE';
    rw_PRAGMA   CONSTANT TokenType := 'PRAGMA';
    rw_RAISE    CONSTANT TokenType := 'RAISE';
    rw_WHILE    CONSTANT TokenType := 'WHILE';
    rw_RETURN   CONSTANT TokenType := 'RETURN';

    -- special tokens
    tk_WhiteSpace        CONSTANT TokenType := '<WhiteSpace>';
    tk_EOF               CONSTANT TokenType := '<EOF>';
    tk_TextLiteral       CONSTANT TokenType := '<TextLiteral>';
    tk_NumberLiteral     CONSTANT TokenType := '<NumberLiteral>';
    tk_SingleLineComment CONSTANT TokenType := '<SingleLineComment>';
    tk_MultiLineComment  CONSTANT TokenType := '<MultiLineComment>';
    tk_Word              CONSTANT TokenType := '<Word>';
    tk_Label             CONSTANT TokenType := '<Label>';

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
