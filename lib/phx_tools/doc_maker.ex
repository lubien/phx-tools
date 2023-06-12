defmodule PhxTools.DocMaker do
  @moduledoc """
  The DocMaker context.
  """
  alias Phoenix.LiveView.Tokenizer

  def list_assigns_in_heex(str) do
    find_assigns_outside_attrs(str) ++ find_assigns_inside_attrs(str)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp find_assigns_outside_attrs(str) do
    str
    |> comp()
    |> find_assigns()
    |> elem(1)
  end

  defp find_assigns_inside_attrs(str) do
    str
    |> tokenize()
    |> Enum.flat_map(& find_assigns_outside_attrs("<%= #{&1} %>"))
  end

  @eex_expr [:start_expr, :expr, :end_expr, :middle_expr]

  defp tokenize(source) do
    {:ok, eex_nodes} = EEx.tokenize(source)
    {tokens, cont} = Enum.reduce(eex_nodes, {[], :text}, &do_tokenize(&1, &2, source))
    Tokenizer.finalize(tokens, "nofile", cont, source)
    |> find_eex_expressions([])
  end

  defp do_tokenize({:text, text, meta}, {tokens, cont}, source) do
    text = List.to_string(text)
    meta = [line: meta.line, column: meta.column]
    state = Tokenizer.init(0, "nofile", source, Phoenix.LiveView.HTMLEngine)
    Tokenizer.tokenize(text, meta, tokens, cont, state)
  end

  defp do_tokenize({:comment, text, meta}, {tokens, cont}, _contents) do
    {[{:eex_comment, List.to_string(text), meta} | tokens], cont}
  end

  defp do_tokenize({type, opt, expr, %{column: column, line: line}}, {tokens, cont}, _contents)
       when type in @eex_expr do
    meta = %{opt: opt, line: line, column: column}
    {[{:eex, type, expr |> List.to_string() |> String.trim(), meta} | tokens], cont}
  end

  defp do_tokenize({:eof, _data}, {tokens, cont}, _contents) do
    {tokens, cont}
  end

  defp find_eex_expressions([], acc), do: acc
  defp find_eex_expressions([{_type, _str, inner, _meta} | rest], acc) when is_list(inner) do
    find_eex_expressions(inner, []) ++ find_eex_expressions(rest, acc)
  end
  defp find_eex_expressions([{_ctx, {:expr, expr, _meta}, _outer_meta} | rest], acc) do
    find_eex_expressions(rest, [expr | acc])
  end
  defp find_eex_expressions([{_type, _subtype, _str, _meta} | rest], acc) do
    find_eex_expressions(rest, acc)
  end
  defp find_eex_expressions([{_type, _str, _meta} | rest], acc) do
    find_eex_expressions(rest, acc)
  end

  # defp eval(string, assigns \\ %{}, binding \\ []) do
  #   # EEx.eval_string(string, [assigns: assigns] ++ binding, file: __ENV__.file, engine: Engine)
  #   EEx.eval_string(string, [assigns: assigns] ++ binding,
  #     file: __ENV__.file,
  #     engine: EEx.SmartEngine
  #   )
  # end

  defp comp(string) do
    EEx.compile_string(string, engine: EEx.SmartEngine)
  end

  defp find_assigns(ast) do
    Macro.prewalk(ast, [], fn
      {{:., _, _}, _, [{:var!, _, _}, assign_name]} = x, acc ->
        {x, [assign_name | acc]}

      x, acc ->
        {x, acc}
    end)
  end
end
