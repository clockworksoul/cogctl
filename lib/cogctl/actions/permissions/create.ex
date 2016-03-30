defmodule Cogctl.Actions.Permissions.Create do
  use Cogctl.Action, "permissions create"

  def option_spec do
    [{:name, :undefined, :undefined, {:string, :undefined}, 'Permission name (required)'}]
  end

  def run(options, _args, _config, endpoint) do
    with_authentication(endpoint,
                        &do_create(&1, :proplists.get_value(:name, options)))
  end

  defp do_create(_endpoint, :undefined) do
    display_arguments_error
  end

  defp do_create(endpoint, "site:" <> name) do
    case CogApi.HTTP.Permissions.create(endpoint, name) do
      {:ok, _resp} ->
        display_output("Created site:#{name}")
      {:error, error} ->
        display_error(error["errors"])
    end
  end

  defp do_create(_endpoint, _name) do
    display_error("Permissions must be created under the site namespace. e.g. site:deploy_blog")
  end
end
