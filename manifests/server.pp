class openldap::server (
  $ensure  = pick($::openldap_server_ensure, 'present'),
  $base_dn = pick($::openldap_server_base_dn, undef),
) {
  include openldap
  include openldap::params

  File {
    owner => '0',
    group => '0',
  }

  case $ensure {
    default: { fail("unrecognized ensure value \"$ensure\"") }
    present, 'present': {
      $service_ensure    = running
      $service_enable    = true
      $service_before    = undef
      $service_require   = Package[$openldap::params::server_package]
    }
    absent, 'absent': {
      $service_ensure    = stopped
      $service_enable    = false
      $service_before    = Package[$openldap::params::server_package]
      $service_require   = undef
    }
  }

  $base_dn_real = $base_dn ? {
    undef   => $openldap::params::base_dn_default,
    default => $base_dn,
  }

  package { $openldap::params::server_package:
    ensure => $ensure,
  }

  realize(Package[$openldap::params::common_package])

  service { $openldap::params::server_service:
    ensure    => $ensure_service,
    enable    => $enable_service,
    before    => $service_before,
    require   => $service_require,
    subscribe => $service_subscribe,
  }

}
