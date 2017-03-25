defmodule Elastic.AWS do

  @moduledoc false
  def enabled? do
    settings().enabled
  end

  #AWSAuth.sign_url(access_key, secret_key, http_method, url, region, service, headers)
  def sign_url(method, url, headers, body) do
    current_settings = settings()
    AWSAuth.sign_url(
      current_settings.access_key_id,
      current_settings.secret_access_key,
      to_string(method),
      url,
      current_settings.region,
      "es",
      process_headers(method, headers),
      DateTime.utc_now |> DateTime.to_naive,
      body
    )
  end

  #AWSAuth.sign_authorization_header(access_key, secret_key, http_method, url, region, service, headers, payload)
  def auth_headers(method, url, headers, body) do
    AWSAuth.sign_authorization_header(
      current_settings.access_key_id,
      current_settings.secret_access_key,
      to_string(method),
      url,
      current_settings.region,
      "es",
      process_headers(method, headers),
      body,
      DateTime.utc_now |> DateTime.to_naive
  end

  # DELETE requests do not support headers
  defp process_headers(:delete, _), do: %{}

  defp process_headers(_method, headers) do
    for {k, v} <- headers,
      into: %{},
      do: {to_string(k), to_string(v)}
  end

  defp settings do
    %{
      enabled: get_setting(:elastic, :aws_enabled),
      access_key_id: get_setting(:elastic, :aws_access_key_id),
      secret_access_key: get_setting(:elastic, :aws_secret_access_key),
      region: get_setting(:elastic, :aws_region)
    }
  end

  defp get_setting(app, key, default \\ nil) when is_atom(app) and is_atom(key) do
    case Application.get_env(app, key) do
      {:system, env_var} ->
        case System.get_env(env_var) do
          nil -> default
          val -> val
        end
      {:system, env_var, preconfigured_default} ->
        case System.get_env(env_var) do
          nil -> preconfigured_default
          val -> val
        end
      nil ->
        default
      val ->
        val
    end
  end
end
