RubyLLM.configure do |config|
  if Rails.env.development?
    # ✅ Local dev uses GitHub Models (OpenAI-compatible endpoint)
    config.openai_api_key  = ENV["GITHUB_TOKEN"]
    config.openai_api_base = "https://models.inference.ai.azure.com"
    config.default_model   = ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-4o-mini")
  else
    # ✅ Production (Heroku) uses your OpenAI key (or set these to GitHub if you prefer)
    config.openai_api_key  = ENV["OPENAI_API_KEY"]
    # leave base default for OpenAI; or set to Azure endpoint if you want GitHub in prod too
    config.default_model   = ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-4o-mini")
  end
end
