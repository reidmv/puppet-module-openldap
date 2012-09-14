define openldap::schema (
  $ensure = present,
  $name   = $title,
  $source = undef,
) {
  include openldap::params

  $schemafile = regsubst($path, '^([^/])', "$openldap::params::schemadir/\\1")

  file { $schemafile:
    ensure => $ensure,
    source => $source,
  }

}
