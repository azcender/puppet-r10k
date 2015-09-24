# Profile for IBM Tivoli Monitoring (ITM) Agent
class profile::itmagent ($exempt = false) {
  unless $exempt {
    include ::profile
    include ::itmagent
  }
}
