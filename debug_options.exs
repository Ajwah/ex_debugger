import Config

config :ex_debugger, :meta_debug,
  all: %{show_module_tokens: false, show_tokenizer: false, show_ast_before: false, show_ast_after: false},
  # "Elixir.Support.DiscoveredBugs.ConsOperator.AutoCase": {true, true, true, true},
  # "Elixir.Support.DiscoveredBugs.ConsOperator.ManualCase": {true, true, true, true},
  placeholder_serving_no_functional_value: "This is only serving as a placeholder to maintain trailing comma of previous line"

config :ex_debugger, :manual_debug,
  capture: :repo, #[:repo, :stdout, :both, :none]
  warn: false,
  all: true,
  placeholder_serving_no_functional_value: "This is only serving as a placeholder to maintain trailing comma of previous line"

config :ex_debugger, :debug,
  capture: :repo, #[:repo, :stdout, :both, :none]
  warn: false,
  all: false,
  "Elixir.HelloWorld": true,
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
  "Elixir.Support.EdgeCases.MultipleDefCases.DefaultParamWithPrivateHelpers": true,
  "Elixir.Support.EdgeCases.MultipleDefCases.Overloading": true,

  "Elixir.Support.EdgeCases.CaseStatement.Minimal": true,
  "Elixir.Support.EdgeCases.CaseStatement.Elaborate": true,

  "Elixir.Support.EdgeCases.IfStatement.Minimal": true,
  "Elixir.Support.EdgeCases.IfStatement.Elaborate": true,

  "Elixir.Support.EdgeCases.CondStatement.Minimal": true,
  "Elixir.Support.EdgeCases.CondStatement.Elaborate": true,

  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithoutExDebugger": true,
  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithExDebugger": true,
  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithExDebugger.Helpers": true,
  "Elixir.Support.EdgeCases.MultipleModules.SiblingsWithExDebugger": true,
  "Elixir.Support.EdgeCases.MultipleModules.SiblingsWithExDebugger.Helpers": true,
  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithExDebuggerButDebugDisabled": true,
  "Elixir.Support.EdgeCases.MultipleModules.SingleNestedWithExDebuggerButDebugDisabled.Helpers": false, # Explicitly disabled

  "Elixir.Support.EdgeCases.ImportCases.MainModuleWithExDebuggerImportingHelperModuleWithExDebugger": true,
  "Elixir.Support.EdgeCases.ImportCases.MainModuleWithExDebuggerImportingHelperModuleWithoutExDebugger": true,
  "Elixir.Support.EdgeCases.ImportCases.HelperModuleWithExDebugger": true,
  "Elixir.Support.EdgeCases.ImportCases.HelperModuleWithoutExDebugger": true,

  "Elixir.Support.EdgeCases.UseCases.HelperModuleWithExDebugger": true,
  "Elixir.Support.EdgeCases.UseCases.HelperModuleWithExDebuggerAtModuleLevel": true,
  "Elixir.Support.EdgeCases.UseCases.HelperModuleWithoutExDebugger": true,
  "Elixir.Support.EdgeCases.UseCases.MainModuleWithExDebuggerUseHelperModuleWithExDebuggerAtModuleLevel": true,
  "Elixir.Support.EdgeCases.UseCases.MainModuleWithExDebuggerUseHelperModuleWithoutExDebugger": true,
  "Elixir.Support.EdgeCases.UseCases.MainModuleWithExDebuggerUseHelperModuleWithExDebugger": true,
  "Elixir.Support.EdgeCases.UseCases.MainModuleWithoutExDebuggerUseHelperModuleWithExDebugger": true,
  "Elixir.Support.EdgeCases.UseCases.MainModuleWithoutExDebuggerUseHelperModuleWithExDebuggerAtModuleLevel": true,

  "Elixir.Support.DiscoveredBugs.ConsOperator.AutoCase": true,
  "Elixir.Support.DiscoveredBugs.ConsOperator.ManualCase": true,
  placeholder_serving_no_functional_value: "This is only serving as a placeholder to maintain trailing comma of previous line"
