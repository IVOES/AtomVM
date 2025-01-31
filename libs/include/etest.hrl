%
% This file is part of AtomVM.
%
% Copyright 2019 Fred Dushin <fred@dushin.net>
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

-define(ASSERT_MATCH(A, B),
    case etest:assert_match(A, B) of
        ok ->
            ok;
        fail ->
            erlang:display(
                {failed_assert_match, {?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY, ?LINE}, A, B}
            ),
            fail
    end
).
-define(ASSERT_EQUALS(A, B),
    case etest:assert_equals(A, B) of
        ok ->
            ok;
        fail ->
            erlang:display(
                {failed_assert_equals, {?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY, ?LINE}, A, B}
            ),
            fail
    end
).
-define(ASSERT_TRUE(C),
    case etest:assert_true(C) of
        ok ->
            ok;
        fail ->
            erlang:display(
                {failed_assert_true, {?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY, ?LINE}, C}
            ),
            fail
    end
).
-define(ASSERT_FAILURE(A),
    case etest:assert_failure(fun() -> A end) of
        ok ->
            ok;
        fail ->
            erlang:display(
                {failed_assert_failure, {?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY, ?LINE}, A}
            ),
            fail
    end
).
-define(ASSERT_FAILURE(A, E),
    case etest:assert_failure(fun() -> A end, E) of
        ok ->
            ok;
        fail ->
            erlang:display(
                {failed_assert_failure, {?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY, ?LINE}, A, E}
            ),
            fail
    end
).
