%
% This file is part of AtomVM.
%
% Copyright 2018 Davide Bettio <davide@uninstall.it>
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

-module(sleep).

-export([start/0, sleep_1/1, sleep_2/1, sleep_3/1, sleep_4/1]).

start() ->
    test_10(0, 0).

% Tolerate 2 failures out of 10
test_10(10, Failed) when Failed > 2 -> 1;
test_10(10, _) ->
    0;
test_10(N, FailCount) ->
    case test(N) of
        ok -> test_10(N + 1, FailCount);
        fail -> test_10(N + 1, FailCount + 1)
    end.

test(Index) ->
    spawn(sleep, sleep_1, [self()]),
    spawn(sleep, sleep_2, [self()]),
    spawn(sleep, sleep_3, [self()]),
    sleep(400),
    FirstValue =
        receive
            Value1 ->
                Value1 * 8
        end,
    SecondValue =
        receive
            Value2 ->
                Value2 * 16
        end,
    ThirdValue =
        receive
            Value3 ->
                Value3 * 32
        end,
    FourthValue =
        receive
            Value4 ->
                Value4 * 64
        end,
    case FirstValue + SecondValue + ThirdValue + FourthValue of
        392 ->
            ok;
        Other ->
            erlang:display({Index, fail, Other, 392}),
            fail
    end.

sleep_1(ParentPid) ->
    sleep(100),
    ParentPid ! 1,
    spawn(sleep, sleep_4, [ParentPid]).

sleep_2(ParentPid) ->
    sleep(200),
    ParentPid ! 2.

sleep_3(ParentPid) ->
    sleep(300),
    ParentPid ! 3.

sleep_4(ParentPid) ->
    sleep(250),
    ParentPid ! 4.

sleep(T) ->
    receive
    after T -> ok
    end.
