create or replace package body plex as


    ----------------------------------------------------------------------------
    procedure initialize(source_lines in source_lines_type) is
    begin
        plex_lexer.initialize(source_lines);
    end;

    ----------------------------------------------------------------------------
    function next_token return plex_token is
    begin
        return plex_lexer.nextToken;
    end;

    ----------------------------------------------------------------------------
    function tokens return plex_tokens is
    begin
        return plex_lexer.tokens;
    end;

end;
/
