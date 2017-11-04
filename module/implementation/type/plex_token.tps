CREATE OR REPLACE Type plex_token AS OBJECT
(
    tokenType       VARCHAR2(30), -- see plex_lexer.TokenType
    text            VARCHAR2(4000),
    sourceIndex     INTEGER, -- position in source composed as concatenation of lines, separated by chr(10)
    sourceLine      INTEGER, -- source line - all_source.line
    sourceLineIndex INTEGER, -- position within source line - all_source.lines

    -- TODO: move methods to some descendant type, do not expose them in API
    CONSTRUCTOR FUNCTION plex_token(tokenType IN VARCHAR2) RETURN SELF AS Result,

    CONSTRUCTOR FUNCTION plex_token
    (
        tokenType IN VARCHAR2,
        text      IN VARCHAR2
    ) RETURN SELF AS Result,

    MEMBER FUNCTION matchText
    (
        text       IN VARCHAR,
        ignoreCase BOOLEAN DEFAULT TRUE
    ) RETURN BOOLEAN
)
/
