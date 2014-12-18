# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::jenkins_worker {
  # Include base class
  include ::profile

  # Include standard jenkins class
  include ::jenkins
  include ::jenkins::slave
}
