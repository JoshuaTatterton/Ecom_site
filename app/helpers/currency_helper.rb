module CurrencyHelper
  CURRENCIES = {
    "GBP" => {
      name: "Pound Sterling",
      iso: "GBP",
      code: "826",
      symbol: "£",
      decimals: 2
    },
    "USD" => {
      name: "United States Dollar",
      iso: "USD",
      code: "840",
      symbol: "$",
      decimals: 2
    },
    "EUR" => {
      name: "Euro",
      iso: "EUR",
      code: "978",
      symbol: "€",
      decimals: 2
    },
    "JPY" => {
      name: "Japanese Yen",
      iso: "JPY",
      code: "392",
      symbol: "¥",
      decimals: 0
    }
  }
  CURRENCY_ISOS = CURRENCIES.keys
end
