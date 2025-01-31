%
% This file is part of AtomVM.
%
% Copyright 2019-2020 Fred Dushin <fred@dushin.net>
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
% SPDX-License-Identifier: Apache-2.0 OR LGPL-2.1-or-later
%

-module(tcp_server).

-export([start/0]).

start() ->
    case gen_tcp:listen(44404, [{active, true}, binary]) of
        {ok, ListenSocket} ->
            io:format("Listening on ~p.~n", [local_address(ListenSocket)]),
            spawn(fun() -> accept(ListenSocket) end),
            sleep_forever();
        Error ->
            io:format("An error occurred listening: ~p~n", [Error])
    end.

accept(ListenSocket) ->
    io:format("Waiting to accept connection...~n"),
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} ->
            io:format("Accepted connection.  local: ~p peer: ~p~n", [
                local_address(Socket), peer_address(Socket)
            ]),
            spawn(fun() -> accept(ListenSocket) end),
            echo();
        Error ->
            io:format("An error occurred accepting connection: ~p~n", [Error])
    end.

echo() ->
    io:format("Waiting to receive data...~n"),
    receive
        {tcp_closed, _Socket} ->
            io:format("Connection closed.~n"),
            ok;
        {tcp, Socket, Packet} ->
            io:format("Received packet ~p from ~p.  Echoing back...~n", [
                Packet, peer_address(Socket)
            ]),
            gen_tcp:send(Socket, Packet),
            echo()
    end.

local_address(Socket) ->
    {ok, SockName} = inet:sockname(Socket),
    to_string(SockName).

peer_address(Socket) ->
    {ok, Peername} = inet:peername(Socket),
    to_string(Peername).

to_string({{A, B, C, D}, Port}) ->
    io_lib:format("~p.~p.~p.~p:~p", [A, B, C, D, Port]).

sleep_forever() ->
    timer:sleep(10000),
    sleep_forever().
