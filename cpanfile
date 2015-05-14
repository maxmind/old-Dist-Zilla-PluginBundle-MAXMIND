requires "Dist::Zilla" => "0";
requires "Dist::Zilla::File::InMemory" => "0";
requires "Dist::Zilla::Plugin::Authority" => "0";
requires "Dist::Zilla::Plugin::AutoPrereqs" => "0";
requires "Dist::Zilla::Plugin::BumpVersionAfterRelease" => "0";
requires "Dist::Zilla::Plugin::CPANFile" => "0";
requires "Dist::Zilla::Plugin::CheckPrereqsIndexed" => "0";
requires "Dist::Zilla::Plugin::CheckVersionIncrement" => "0";
requires "Dist::Zilla::Plugin::CopyFilesFromBuild" => "0";
requires "Dist::Zilla::Plugin::Git::Check" => "0";
requires "Dist::Zilla::Plugin::Git::CheckFor::MergeConflicts" => "0";
requires "Dist::Zilla::Plugin::Git::Commit" => "0";
requires "Dist::Zilla::Plugin::Git::Contributors" => "0";
requires "Dist::Zilla::Plugin::Git::GatherDir" => "0";
requires "Dist::Zilla::Plugin::Git::Push" => "0";
requires "Dist::Zilla::Plugin::Git::Tag" => "0";
requires "Dist::Zilla::Plugin::GitHub::Meta" => "0";
requires "Dist::Zilla::Plugin::GitHub::Update" => "0";
requires "Dist::Zilla::Plugin::InstallGuide" => "0";
requires "Dist::Zilla::Plugin::Meta::Contributors" => "0";
requires "Dist::Zilla::Plugin::MetaConfig" => "0";
requires "Dist::Zilla::Plugin::MetaJSON" => "0";
requires "Dist::Zilla::Plugin::MetaProvides::Package" => "0";
requires "Dist::Zilla::Plugin::MetaResources" => "0";
requires "Dist::Zilla::Plugin::MinimumPerl" => "0";
requires "Dist::Zilla::Plugin::MojibakeTests" => "0";
requires "Dist::Zilla::Plugin::NextRelease" => "0";
requires "Dist::Zilla::Plugin::PodSyntaxTests" => "0";
requires "Dist::Zilla::Plugin::PromptIfStale" => "0";
requires "Dist::Zilla::Plugin::ReadmeAnyFromPod" => "0";
requires "Dist::Zilla::Plugin::RewriteVersion" => "0";
requires "Dist::Zilla::Plugin::SurgicalPodWeaver" => "0";
requires "Dist::Zilla::Plugin::Test::CPAN::Changes" => "0";
requires "Dist::Zilla::Plugin::Test::Compile" => "0";
requires "Dist::Zilla::Plugin::Test::EOL" => "0.14";
requires "Dist::Zilla::Plugin::Test::NoTabs" => "0";
requires "Dist::Zilla::Plugin::Test::Pod::Coverage::Configurable" => "0";
requires "Dist::Zilla::Plugin::Test::PodSpelling" => "0";
requires "Dist::Zilla::Plugin::Test::Portability" => "0";
requires "Dist::Zilla::Plugin::Test::ReportPrereqs" => "0";
requires "Dist::Zilla::Plugin::Test::Synopsis" => "0";
requires "Dist::Zilla::Plugin::Test::TidyAll" => "0";
requires "Dist::Zilla::Plugin::Test::Version" => "0";
requires "Dist::Zilla::Role::AfterBuild" => "0";
requires "Dist::Zilla::Role::BeforeBuild" => "0";
requires "Dist::Zilla::Role::LicenseProvider" => "0";
requires "Dist::Zilla::Role::PluginBundle::Easy" => "0";
requires "Dist::Zilla::Role::PluginBundle::PluginRemover" => "0";
requires "Dist::Zilla::Role::TextTemplate" => "0";
requires "Module::Runtime" => "0";
requires "Moose" => "0";
requires "Perl::Critic::Moose" => "1.01";
requires "Pod::Weaver::Section::Contributors" => "0";
requires "String::RewritePrefix" => "0";
requires "autodie" => "0";
requires "namespace::autoclean" => "0";
requires "perl" => "v5.10.0";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "Test::More" => "0.96";
  requires "perl" => "v5.10.0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "perl" => "v5.10.0";
};

on 'develop' => sub {
  requires "Code::TidyAll" => "0.24";
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Perl::Critic" => "1.123";
  requires "Perl::Tidy" => "20140711";
  requires "Test::CPAN::Changes" => "0.19";
  requires "Test::Code::TidyAll" => "0.24";
  requires "Test::EOL" => "0";
  requires "Test::More" => "0.88";
  requires "Test::NoTabs" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Spelling" => "0.12";
  requires "Test::Synopsis" => "0";
  requires "Test::Version" => "1";
};
