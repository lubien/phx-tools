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
    |> EEx.compile_string(engine: EEx.SmartEngine)
    |> Macro.prewalk([], fn
      {{:., _, _}, _, [{:var!, _, _}, assign_name]} = x, acc ->
        {x, [assign_name | acc]}

      x, acc ->
        {x, acc}
    end)
    |> elem(1)
  end

  defp find_assigns_inside_attrs(str) do
    str
    |> tokenize()
    |> Enum.flat_map(& find_assigns_outside_attrs("<%= #{&1} %>"))
  end

  defp tokenize(source) do
    {:ok, eex_nodes} = EEx.tokenize(source)
    {tokens, cont} = Enum.reduce(eex_nodes, {[], :text}, &do_tokenize(&1, &2, source))
    Tokenizer.finalize(tokens, "nofile", cont, source)
    |> find_eex_expressions([])
  end

  defp do_tokenize({:text, text, _meta}, {tokens, cont}, contents) do
    text = List.to_string(text)
    meta = []
    state = Tokenizer.init(0, "nofile", contents, Phoenix.LiveView.HTMLEngine)
    Tokenizer.tokenize(text, meta, tokens, cont, state)
  end

  defp do_tokenize(_anything, {tokens, cont}, _contents) do
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
end
