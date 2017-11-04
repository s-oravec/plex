create or replace package plex as


    type source_lines_type is table of all_source.text%type;

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
