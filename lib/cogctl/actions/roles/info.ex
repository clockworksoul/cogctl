defmodule Cogctl.Actions.Roles.Info do
  use Cogctl.Action, "roles info"
  import Cogctl.Actions.Roles.Util, only: [render: 3]

  def option_spec do
    [{:role, :undefined, :undefined, :string, 'Role name (required)'},
     {:permissions, :undefined, 'permissions', {:boolean, false}, 'Flag to display Permissions data'},
     {:groups, :undefined, 'groups', {:boolean, false}, 'Flag to display Groups data'}]
  end

  def run(options, _args, _config, endpoint) do
    params = convert_to_params(options)
    with_authentication(endpoint, &do_info(&1, params))
  end

  defp do_info(endpoint, params) do
    case CogApi.HTTP.Client.role_show(endpoint, %{name: params.role}) do
      {:ok, role} ->
        groups = if params.groups do
          role.groups
        end

        permissions = if params.permissions do
          role.permissions
        end

        render(role, groups, permissions)
      {:error, error} ->
        display_error(error)
    end
  end

end
