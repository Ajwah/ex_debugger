import Config

config :ex_debugger, :meta_debug,
  # all: %{show_tokenizer: false, show_ast_before: false, show_ast_after: false},
  # "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithoutExDebugger": {true, true, true}

  all: %{show_module_tokens: false, show_tokenizer: false, show_ast_before: false, show_ast_after: false},
  "Elixir.Support.EdgeCases.CaseStatement.Elaborate": {true, true, true, true}

config :ex_debugger, :debug,
  capture: :repo, #[:repo, :stdout, :both]
  all: false,
  "Elixir.Support.EdgeCases.EmptyCase": true,
  "Elixir.Support.EdgeCases.SingleDefCases.ContractedFormSimple": true,
  "Elixir.Support.EdgeCases.SingleDefCases.ContractedFormComplex": true,
  "Elixir.Support.EdgeCases.SingleDefCases.ExpandedFormSimple": true,
  "Elixir.Support.EdgeCases.SingleDefCases.ExpandedFormComplex": true,
  "Elixir.Support.EdgeCases.SingleDefCases.ExpandedFormComplex.SingularArgument": true,
  "Elixir.Support.EdgeCases.SingleDefCases.ExpandedFormComplex.PatternMatch": true,
  "Elixir.Support.EdgeCases.SingleDefCases.ExpandedFormComplex.MultipleArgument": true,
  "Elixir.Support.EdgeCases.SingleDefCases.ExpandedFormComplex.Defguard": true,
  "Elixir.Support.EdgeCases.SingleDefCases.ExpandedFormComplex.MultipleIndependentExpressions": true,
  "Elixir.Support.EdgeCases.MultipleDefCases.Various": true,
  "Elixir.Support.EdgeCases.MultipleDefCases.UselessSpaces": true,
  "Elixir.Support.EdgeCases.CaseStatement.Minimal": true,
  "Elixir.Support.EdgeCases.CaseStatement.Elaborate": true,
  "Elixir.Support.EdgeCases.MultipleDefCases.DefaultParamWithPrivateHelpers": true,
  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithoutExDebugger": true,
  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithExDebugger": true,
  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithExDebugger.Helpers": true,
  "Elixir.Support.EdgeCases.MultipleModules.SiblingsWithExDebugger": true,
  "Elixir.Support.EdgeCases.MultipleModules.SiblingsWithExDebugger.Helpers": true,
  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithExDebuggerButDebugDisabled": true,
  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithExDebuggerButDebugDisabled.Helpers": false, # Explicitly disabled
  "Elixir.Support.EdgeCases.MultipleDefCases.Overloading": true,
  none: false
