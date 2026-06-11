use crate::domain::ProviderDefinition;

use super::{
    brave::BraveProvider, deepseek::DeepSeekProvider, serpapi::SerpApiProvider,
    tavily::TavilyProvider, ProviderClient,
};

pub fn provider_clients() -> Vec<Box<dyn ProviderClient>> {
    vec![
        Box::<TavilyProvider>::default(),
        Box::<BraveProvider>::default(),
        Box::<SerpApiProvider>::default(),
        Box::<DeepSeekProvider>::default(),
    ]
}

pub fn registered_provider_ids() -> Vec<&'static str> {
    provider_clients()
        .iter()
        .map(|client| client.provider_id())
        .collect()
}

pub fn visible_provider_definitions() -> Vec<ProviderDefinition> {
    vec![
        ProviderDefinition::new_ai_search(
            "tavily",
            "Tavily",
            "Tavily",
            "tavily",
            "https://app.tavily.com/home",
            false,
        ),
        ProviderDefinition::new_ai_search(
            "brave",
            "Brave",
            "Brave",
            "brave",
            "https://api.search.brave.com/app/dashboard",
            true,
        ),
        ProviderDefinition::new_ai_search(
            "serpapi",
            "SerpAPI",
            "SerpAPI",
            "serpapi",
            "https://serpapi.com/dashboard",
            false,
        ),
        ProviderDefinition::new_llm(
            "deepseek",
            "DeepSeek",
            "DeepSeek",
            "Balance",
            "deepseek",
            "https://platform.deepseek.com/usage",
        ),
    ]
}

pub fn visible_provider_ids() -> Vec<&'static str> {
    vec!["tavily", "brave", "serpapi", "deepseek"]
}
