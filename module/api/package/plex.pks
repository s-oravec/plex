create or replace package plex as

    type source_lines_type is table of all_source.text%type;

    subtype token_type is varchar2(30);

    -- Special characters
    -- order is significant
    -- assign has to be before colon as colon is its prefix
    tk_Asterix         CONSTANT token_type := '*';
    tk_Assign          CONSTANT token_type := ':=';
    tk_Colon           CONSTANT token_type := ':';
    tk_Comma           CONSTANT token_type := ',';
    tk_Dollar          CONSTANT token_type := '$';
    tk_Dot             CONSTANT token_type := '.';
    tk_Equals          CONSTANT token_type := '=';
    tk_ExclamationMark CONSTANT token_type := '!';
    tk_GreaterThan     CONSTANT token_type := '>';
    tk_Hash            CONSTANT token_type := '#';
    tk_LessThan        CONSTANT token_type := '<';
    tk_LParenth        CONSTANT token_type := '(';
    tk_MinusChar       CONSTANT token_type := '-';
    tk_Percent         CONSTANT token_type := '%';
    tk_PipeChar        CONSTANT token_type := '|';
    tk_PlusChar        CONSTANT token_type := '+';
    tk_Quote           CONSTANT token_type := '"';
    tk_RParenth        CONSTANT token_type := ')';
    tk_Semicolon       CONSTANT token_type := ';';
    tk_Slash           CONSTANT token_type := '/';
    tk_Underscore      CONSTANT token_type := '_';

    -- Reserved words
    tk_ALL        CONSTANT token_type := 'ALL';
    tk_ALTER      CONSTANT token_type := 'ALTER';
    tk_AND        CONSTANT token_type := 'AND';
    tk_ANY        CONSTANT token_type := 'ANY';
    tk_AS         CONSTANT token_type := 'AS';
    tk_ASC        CONSTANT token_type := 'ASC';
    tk_AT         CONSTANT token_type := 'AT';
    tk_BEGIN      CONSTANT token_type := 'BEGIN';
    tk_BETWEEN    CONSTANT token_type := 'BETWEEN';
    tk_BY         CONSTANT token_type := 'BY';
    tk_CASE       CONSTANT token_type := 'CASE';
    tk_CLUSTER    CONSTANT token_type := 'CLUSTER';
    tk_CLUSTERS   CONSTANT token_type := 'CLUSTERS';
    tk_COLAUTH    CONSTANT token_type := 'COLAUTH';
    tk_COLUMNS    CONSTANT token_type := 'COLUMNS';
    tk_COMPRESS   CONSTANT token_type := 'COMPRESS';
    tk_CONNECT    CONSTANT token_type := 'CONNECT';
    tk_CRASH      CONSTANT token_type := 'CRASH';
    tk_CREATE     CONSTANT token_type := 'CREATE';
    tk_CURSOR     CONSTANT token_type := 'CURSOR';
    tk_DECLARE    CONSTANT token_type := 'DECLARE';
    tk_DEFAULT    CONSTANT token_type := 'DEFAULT';
    tk_DESC       CONSTANT token_type := 'DESC';
    tk_DISTINCT   CONSTANT token_type := 'DISTINCT';
    tk_DROP       CONSTANT token_type := 'DROP';
    tk_ELSE       CONSTANT token_type := 'ELSE';
    tk_END        CONSTANT token_type := 'END';
    tk_EXCEPTION  CONSTANT token_type := 'EXCEPTION';
    tk_EXCLUSIVE  CONSTANT token_type := 'EXCLUSIVE';
    tk_FETCH      CONSTANT token_type := 'FETCH';
    tk_FOR        CONSTANT token_type := 'FOR';
    tk_FROM       CONSTANT token_type := 'FROM';
    tk_FUNCTION   CONSTANT token_type := 'FUNCTION';
    tk_GOTO       CONSTANT token_type := 'GOTO';
    tk_GRANT      CONSTANT token_type := 'GRANT';
    tk_GROUP      CONSTANT token_type := 'GROUP';
    tk_HAVING     CONSTANT token_type := 'HAVING';
    tk_CHECK      CONSTANT token_type := 'CHECK';
    tk_IDENTIFIED CONSTANT token_type := 'IDENTIFIED';
    tk_IF         CONSTANT token_type := 'IF';
    tk_IN         CONSTANT token_type := 'IN';
    tk_INDEX      CONSTANT token_type := 'INDEX';
    tk_INDEXES    CONSTANT token_type := 'INDEXES';
    tk_INSERT     CONSTANT token_type := 'INSERT';
    tk_INTERSECT  CONSTANT token_type := 'INTERSECT';
    tk_INTO       CONSTANT token_type := 'INTO';
    tk_IS         CONSTANT token_type := 'IS';
    tk_LIKE       CONSTANT token_type := 'LIKE';
    tk_LOCK       CONSTANT token_type := 'LOCK';
    tk_MINUS      CONSTANT token_type := 'MINUS';
    tk_MODE       CONSTANT token_type := 'MODE';
    tk_NOCOMPRESS CONSTANT token_type := 'NOCOMPRESS';
    tk_NOT        CONSTANT token_type := 'NOT';
    tk_NOWAIT     CONSTANT token_type := 'NOWAIT';
    tk_NULL       CONSTANT token_type := 'NULL';
    tk_OF         CONSTANT token_type := 'OF';
    tk_ON         CONSTANT token_type := 'ON';
    tk_OPTION     CONSTANT token_type := 'OPTION';
    tk_OR         CONSTANT token_type := 'OR';
    tk_ORDER      CONSTANT token_type := 'ORDER';
    tk_OVERLAPS   CONSTANT token_type := 'OVERLAPS';
    tk_PROCEDURE  CONSTANT token_type := 'PROCEDURE';
    tk_PUBLIC     CONSTANT token_type := 'PUBLIC';
    tk_RESOURCE   CONSTANT token_type := 'RESOURCE';
    tk_REVOKE     CONSTANT token_type := 'REVOKE';
    tk_SELECT     CONSTANT token_type := 'SELECT';
    tk_SHARE      CONSTANT token_type := 'SHARE';
    tk_SIZE       CONSTANT token_type := 'SIZE';
    tk_SQL        CONSTANT token_type := 'SQL';
    tk_START      CONSTANT token_type := 'START';
    tk_SUBTYPE    CONSTANT token_type := 'SUBTYPE';
    tk_TABAUTH    CONSTANT token_type := 'TABAUTH';
    tk_TABLE      CONSTANT token_type := 'TABLE';
    tk_THEN       CONSTANT token_type := 'THEN';
    tk_TO         CONSTANT token_type := 'TO';
    tk_TYPE       CONSTANT token_type := 'TYPE';
    tk_UNION      CONSTANT token_type := 'UNION';
    tk_UNIQUE     CONSTANT token_type := 'UNIQUE';
    tk_UPDATE     CONSTANT token_type := 'UPDATE';
    tk_VALUES     CONSTANT token_type := 'VALUES';
    tk_VIEW       CONSTANT token_type := 'VIEW';
    tk_VIEWS      CONSTANT token_type := 'VIEWS';
    tk_WHEN       CONSTANT token_type := 'WHEN';
    tk_WHERE      CONSTANT token_type := 'WHERE';
    tk_WITH       CONSTANT token_type := 'WITH';

    -- reserved words
    tk_BODY     CONSTANT token_type := 'BODY';
    tk_CLOSE    CONSTANT token_type := 'CLOSE';
    tk_CONSTANT CONSTANT token_type := 'CONSTANT';
    tk_CONTINUE CONSTANT token_type := 'CONTINUE';
    tk_ELSIF    CONSTANT token_type := 'ELSIF';
    tk_EXECUTE  CONSTANT token_type := 'EXECUTE';
    tk_EXIT     CONSTANT token_type := 'EXIT';
    tk_LOOP     CONSTANT token_type := 'LOOP';
    tk_FORALL   CONSTANT token_type := 'FORALL';
    tk_MERGE    CONSTANT token_type := 'MERGE';
    tk_OPEN     CONSTANT token_type := 'OPEN';
    tk_PACKAGE  CONSTANT token_type := 'PACKAGE';
    tk_PIPE     CONSTANT token_type := 'PIPE';
    tk_PRAGMA   CONSTANT token_type := 'PRAGMA';
    tk_RAISE    CONSTANT token_type := 'RAISE';
    tk_WHILE    CONSTANT token_type := 'WHILE';
    tk_RETURN   CONSTANT token_type := 'RETURN';

    -- special tokens
    tk_WhiteSpace        CONSTANT token_type := '<WhiteSpace>';
    tk_EOF               CONSTANT token_type := '<EOF>';
    tk_TextLiteral       CONSTANT token_type := '<TextLiteral>';
    tk_NumberLiteral     CONSTANT token_type := '<NumberLiteral>';
    tk_SingleLineComment CONSTANT token_type := '<SingleLineComment>';
    tk_MultiLineComment  CONSTANT token_type := '<MultiLineComment>';
    tk_Word              CONSTANT token_type := '<Word>';
    tk_Label             CONSTANT token_type := '<Label>';

    /**
    Initialize Lexer from source lines

    Note: Initialize from dictionary would require plex to have excesive
          and unnecessary privileges,  therefore there is initialize
          method that takes source lines as parameter and the caller is
          responsible for obtaining them

    %param source_lines
    */
    procedure initialize(source_lines in source_lines_type);

    /**
    Returns next token

    %return plex_token token object
    */
    function next_token return plex_token;

    /**
    Returns table of token objects

    %return plex_tokens table of token objects
    */
    function tokens return plex_tokens;

end;
/
