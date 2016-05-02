defmodule Cogctl.Actions.Users.Info do
  use Cogctl.Action, "users info"
  import Cogctl.Actions.Users.Util

  def option_spec do
    [{:user, :undefined, :undefined, :string, 'User username (required)'},
     {:groups, :undefined, 'groups', {:boolean, false}, 'Flag to display groups (default false)'},
     {:roles, :undefined, 'roles', {:boolean, false}, 'Flag to display roles (default false)'}]
  end

  def run(options, _args, _config, endpoint) do
    params = convert_to_params(options)
    with_authentication(endpoint, &do_info(&1, params))
  end

  defp do_info(endpoint, params) do
    case CogApi.HTTP.Client.user_show(endpoint, %{username: params.user}) do
      {:ok, user} ->
        all = fn(:get, data, next) ->
          Enum.flat_map(data, &next.(Map.delete(&1, :__struct__)))
        end

        groups = if params.groups do
          user.groups
        end
        roles = if params.roles do
          get_in(user.groups, [all, :roles])
        end

        render(user, groups, roles)
      error ->
        display_error(error)
    end
  end
end
