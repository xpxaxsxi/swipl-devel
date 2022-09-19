% Provide an HTTP server to make   the  various components available. To
% use it, build the wasm version  in   e.g.,  `build.wasm` and from this
% directory, run
%
%     swipl ../src/wasm/server.pl
%
:- use_module(library(http/http_server)).
:- use_module(library(http/http_files)).
:- use_module(library(main)).
:- use_module(library(option)).

user:file_search_path(source, '../src/wasm').
user:file_search_path(wasm,   'src').
user:file_search_path(scasp,  Dir) :-
    getenv('SCASP_HOME', Dir).

:- http_handler('/', http_redirect(see_other, '/wasm/'), []).
:- http_handler('/wasm/',
                http_reply_file(source('index.html'), []), []).
:- http_handler('/wasm/shell',
                http_reply_file(
                    source('shell.html'),
                    [ headers([ 'Cross-Origin-Opener-Policy'('same-origin'),
                                'Cross-Origin-Embedder-Policy'('require-corp')
                              ])]),
                []).
:- http_handler('/wasm/swipl-web.js',
                http_reply_file(wasm('swipl-web.js'), []), []).
:- http_handler('/wasm/swipl-web.worker.js',
                http_reply_file(wasm('swipl-web.worker.js'), []), []).
:- http_handler('/wasm/swipl-web.data',
                http_reply_file(wasm('swipl-web.data'), []), []).
:- http_handler('/wasm/swipl-web.wasm',
                http_reply_file(wasm('swipl-web.wasm'), []), []).

% Test code
:- http_handler('/wasm/test',
                http_reply_file(
                    source('test.html'),
                    [ headers([ 'Cross-Origin-Opener-Policy'('same-origin'),
                                'Cross-Origin-Embedder-Policy'('require-corp')
                              ])]),
                []).
:- http_handler('/wasm/test.pl',
                http_reply_file(source('test.pl'), []), []).
:- http_handler('/wasm/test.qlf',
                http_reply_file(source('test.qlf'), []), []).


:- http_handler('/wasm/cbg',
                http_reply_file(
                    source('cbg.html'),
                    [ headers([ 'Cross-Origin-Opener-Policy'('same-origin'),
                                'Cross-Origin-Embedder-Policy'('require-corp')
                              ])]),
                []).


:- if(absolute_file_name(scasp(.), _, [file_type(directory)])).
:- http_handler('/wasm/scasp/', http_reply_from_files(scasp(.), []), [prefix]).
:- endif.


:- initialization(server_loop, main).

opt_type(port, port, nonneg).
opt_help(port, "Port to listen to (default 8080)").

server :-
    current_prolog_flag(argv, Argv),
    argv_options(Argv, _Positonal, Options),
    merge_options(Options, [port(8080)], Options1),
    http_server(Options1).

server_loop :-
    server,
    thread_get_message(quit).

