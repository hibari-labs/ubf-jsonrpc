-module(jsf_tests).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").

-define(PRINTRESULT,
    case Out of
        Exp ->
            %%io:format("~p:~p:~p:~p~n  In =~p~n  Out=~p~n", [?MODULE, Tst, Acc, Desc, In, Out]),
            ok;
        _ ->
            io:format("### FAILED:~p:~p:~p:~p~n  In =~p~n  Out=~p~n", [?MODULE, Tst, Acc, Desc, In, Out]),
            io:format("  Exp=~p~n", [Exp])
    end
).


jsf_test() ->
    true = test_json_decode_1(),
    true = test_json_decode_2(),
    true = test_json_encode_1(),
    true = test_jsf_decode_1(),
    true = test_jsf_encode_1(),
    true.


%% jsf encode: ubf -> json
%%     decode: ubj <- json

test_json_decode_1() ->
    Tst = test_json_decode_1,
    lists:foldl(
        fun({Desc, In, Exp, _}, Acc) ->
            Out = mochijson2:decode(In),
            ?PRINTRESULT,
            Out = Exp,
            Acc + 1
        end,
        1,
        data1()
    ),
    true.

test_json_decode_2() ->
    {error,syntax_error} = jsf:decode(<<"#5&4&3&2&1&$">>),
    true.

test_json_encode_1() ->
    Tst = test_json_encode_1,
    lists:foldl(
        fun({Desc, Exp, In, _}, Acc) ->
            Out = iolist_to_binary(mochijson2:encode(In)),
            ?PRINTRESULT,
            Out = Exp,
            Acc + 1
        end,
        1,
        data1()
    ),
    true.

test_jsf_decode_1() ->
    Tst = test_jsf_decode_1,
    lists:foldl(
        fun({Desc, In, _, Exp}, Acc) ->
            {done, Out, <<>>, undefined} = jsf:decode(In, jsf_test_plugin),
            ?PRINTRESULT,
            Out = Exp,
            Acc + 1
        end,
        1,
        data1()
    ),
    true.

test_jsf_encode_1() ->
    Tst = test_jsf_encode_1,
    lists:foldl(
        fun({Desc, Exp, _, In}, Acc) ->
            Out = jsf:encode(In, jsf_test_plugin),
            ?PRINTRESULT,
            Out = Exp,
            Acc + 1
        end,
        1,
        data1()
    ),
    true.

data1() ->
    [
        %% description
        %% JSON - string()
        %% ERLANG - term()
        %% UBF - term()
        {
            "JSON true"
            , <<"true">>
            , true
            , true
        }, {
            "JSON false"
            , <<"false">>
            , false
            , false
        }, {
            "JSON null - UBF undefined"
            , <<"null">>
            , null
            , undefined
        }, {
            "JSON 101"
            , <<"101">>
            , 101
            , 101
        }, {
            "JSON 1.5"
            , <<"1.5">>
            , 1.5
            , 1.5
        }, {
            "JSON array"
            , <<"[1,2,3]">>
            , [1,2,3]
            , [1,2,3]
        }, {
            "JSON object"
            , <<"{\"key1\":\"a\",\"key2\":2}">>
            , {struct, [{<<"key1">>, <<"a">>}, {<<"key2">>, 2}] }
            , {'#P', [{<<"key1">>, <<"a">>}, {<<"key2">>, 2}] }
        }, {
            "JSON object - UBF atom"
            , <<"{\"$A\":\"atomname\"}">>
            , {struct, [{<<"$A">>, <<"atomname">>}] }
            , atomname
        }, {
            "JSON object - UBF string"
            , <<"{\"$S\":\"stringval\"}">>
            , {struct, [{<<"$S">>, <<"stringval">>}] }
            , {'#S', "stringval"}
        }, {
            "JSON object - UBF tuple"
            , <<"{\"$T\":[\"a\",2]}">>
            , {struct, [{<<"$T">>, [<<"a">>, 2]}] }
            , {<<"a">>, 2}
        }, {
            "JSON object - UBF record"
            , <<"{\"$R\":\"dummyrecord\",\"bar\":\"2\",\"foo\":1}">>
            , {struct, [{<<"$R">>, <<"dummyrecord">>}, {<<"bar">>, <<"2">>}, {<<"foo">>, 1}] }
            , {dummyrecord, 1, <<"2">>}
        }
    ].
