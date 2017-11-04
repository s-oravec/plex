CREATE OR REPLACE Type plex_integer_stack  AS OBJECT
(

    stack_items plex_integer_tab,

    CONSTRUCTOR FUNCTION plex_integer_stack RETURN SELF AS Result,
    MEMBER PROCEDURE push
    (
        SELF   IN OUT plex_integer_stack,
        p_item INTEGER
    ),
    MEMBER FUNCTION pop(SELF IN OUT plex_integer_stack) RETURN INTEGER,
    MEMBER PROCEDURE pop(SELF IN OUT plex_integer_stack),
    -- 1 true, 0 false
    MEMBER FUNCTION isEmtpy(SELF IN OUT plex_integer_stack) RETURN INTEGER

)
/
