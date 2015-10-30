-module(dispatch_compiler_tests).

-include_lib("eunit/include/eunit.hrl").

-define(M, '-dispatch-test-').

-export([
    is_foo/2
]).

simple_test() ->
    Rules = [
        {home, [], x, []},
        {a, ["a"], x, []},
        {ab, ["a", "b"], x, []},
        {abc, ["a", "b", "c"], x, []},
        {abv, ["a", "b", v], x, []},
        {avc, ["a", v, "c"], x, []},
        {avw, ["a", v, w], x, []}
    ],
    {ok, Module} = dispatch_compiler:compile_load(?M, Rules),
    ?assertEqual({ok, {{home, [], x, []}, []}},
                 Module:match("", none)),

    ?assertEqual({ok, {{a, ["a"], x, []}, []}},
                 Module:match([<<"a">>], none)),

    ?assertEqual({ok, {{abc, ["a", "b", "c"], x, []}, []}},
                 Module:match([<<"a">>, <<"b">>, <<"c">>], none)),

    ?assertEqual({ok, {{abv, ["a", "b", v], x, []}, [{v, <<"d">>}]}},
                 Module:match([<<"a">>, <<"b">>, <<"d">>], none)),

    ?assertEqual({ok, {{avc, ["a", v, "c"], x, []}, [{v, <<"e">>}]}},
                 Module:match([<<"a">>, <<"e">>, <<"c">>], none)),

    ?assertEqual({ok, {{avw, ["a", v, w], x, []}, [{v, <<"e">>}, {w, <<"f">>}]}},
                 Module:match([<<"a">>, <<"e">>, <<"f">>], none)),

    ?assertEqual(fail,
                 Module:match([<<"a">>, <<"b">>, <<"c">>, <<"d">>], none)),

    ?assertEqual(fail,
                 Module:match([<<"c">>], none)).

wildcard_test() ->
    Rules = [
        {image, ["image", '*'], x, []}
    ],
    {ok, Module} = dispatch_compiler:compile_load(?M, Rules),
    ?assertEqual({ok, {{image, ["image", '*'], x, []}, [{'*', [<<"foo">>, <<"bar">>]}]}},
                 Module:match([<<"image">>, <<"foo">>, <<"bar">>], none)),

    ?assertEqual(fail,
                 Module:match([<<"image">>], none)).

wildcard2_test() ->
    Rules = [
        {all, ['*'], x, []}
    ],
    {ok, Module} = dispatch_compiler:compile_load(?M, Rules),
    ?assertEqual({ok, {{all, ['*'], x, []}, [{'*', [<<"image">>, <<"foo">>, <<"bar">>]}]}},
                 Module:match([<<"image">>, <<"foo">>, <<"bar">>], none)).


re_test() ->
    Rules = [
        {nr, ["id", {v, "^[0-9]+$"}], x, []},
        {nr, ["id", foo], x, []}
    ],
    {ok, Module} = dispatch_compiler:compile_load(?M, Rules),
    ?assertEqual({ok, {{nr, ["id", {v, "^[0-9]+$"}], x, []}, [{v, <<"1234">>}]}},
                 Module:match([<<"id">>, <<"1234">>], none)),

    ?assertEqual({ok, {{nr, ["id", foo], x, []}, [{foo, <<"bar">>}]}},
                 Module:match([<<"id">>, <<"bar">>], none)).


mf_test() ->
    Rules = [
        {a, ["id", {foo, {?MODULE, is_foo}}], x, []},
        {b, ["id", "foo"], x, []},
        {c, ["id", foo], x, []}
    ],
    {ok, Module} = dispatch_compiler:compile_load(?M, Rules),
    ?assertEqual({ok, {{a, ["id", {foo, {?MODULE, is_foo}}], x, []}, [{foo, <<"foo">>}]}},
                 Module:match([<<"id">>, <<"foo">>], none)),

    ?assertEqual({ok, {{c, ["id", foo], x, []}, [{foo, <<"bar">>}]}},
                 Module:match([<<"id">>, <<"bar">>], none)).


is_foo(<<"foo">>, none) -> true;
is_foo(_Other, none) -> false.
