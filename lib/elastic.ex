defmodule Elastic do
  @moduledoc ~S"""

  Elastic is a thin veneer over HTTPotion to help you talk to your Elastic Search stores.

  Elastic provides five main ways of talking to the stores:

  * `Elastic.Document.API`: Adds functions to a module to abstract away some of the mess of actions on an index.
  * `Elastic.Index`: Functions for working with indexes.
  * `Elastic.Bulk`: Provides functions for bulk creating or updating documents in an ElasticSearch store.
  * `Elastic.Scroller`: A server which works with Elastic Search's [Scroll API](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-request-scroll.html).
  * `Elastic.HTTP`: A very thin veneer / low-level API over HTTPotion and Poison to make queries to your Elastic Search store.


  ## Configuration

  You can configure the way Elastic behaves by using the following configuration options:

  * `base_url`: Where your Elastic Search instance is located. Defaults to http://localhost:9200.
  * `index_prefix`: A prefix to use for all indexes. Only used when using the Document API, or `Elastic.Index`.
  * `use_mix_env`: Adds `Mix.env` to an index, so that the index name used is something like `dev_answer`. Can be used in conjunction with `index_prefix` to get things like `company_dev_answer` as the index name.

  ### AWS Configuration

  If your Elastic Search store is hosted on AWS, there are configuration options for that:

  ```elixir
  config :elastic,
    base_url: "https://your-amazon-es-endpoint-goes-here",
    aws: %{
      enabled: true,
      access_key_id: "ACCESS_KEY_ID_GOES_HERE",
      secret_access_key: "SECRET_ACCESS_KEY_GOES_HERE",
      region: "REGION_GOES_HERE"
    }
  ```

  Elastic will then use the `AWSAuth` library to sign URLs for requests to this store.
  """

  def base_url do
    get_setting(:elastic, :base_url)
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
