module CloneMysql

  class Mysqld

    attr_accessor :mysql_pid_file

    def initialize(datadir,port=3306,clone_pid_file='/tmp/mysql_clone.pid',defaults_file='/opt/local/etc/mysql_clone.cnf',initfile=nil)
      @datadir = datadir
      @port = port
      @initfile = initfile
      @defaults_file = defaults_file
      @clone_pid_file = clone_pid_file
      @mysql_pid_file = '/var/mysql/mysql.pid'
    end

    def is_main_mysqld_running?
      if File.file?(@mysql_pid_file)
        pid = File.open(@mysql_pid_file).read.strip().to_i
        begin
          Process.getpgid(pid)
          return true
        rescue Errno::ESRCH
          return false
        end
      else
        return false
      end
    end

    def self.stop(pid_file='/tmp/mysql_clone.pid')
      if File.file?(pid_file)
        pid = File.open(pid_file).read.strip.to_i
        Process.kill("TERM", pid)
        puts("Sent sig TERM to mysql pid, confirm it has stopped")
      else
        puts("A cloned mysqld does not appear to be running, you should manually verify")
      end
    end

    def start()
      if is_main_mysqld_running?
        exit_now!("The Mysqld service is running please, svcadm disable mysql, first")
      end

      cmd = []
      cmd << "/opt/local/libexec/mysqld"
      cmd << "--defaults-file=#{@defaults_file}"
      cmd << "--user=mysql"
      cmd << "--basedir=/opt/local"
      cmd << "--datadir=#{@datadir}"
      cmd << "--pid-file=#{@clone_pid_file}"
      cmd << "--port=#{@port}"
      cmd << "--skip-slave-start"
      cmd << "--log-error=#{@datadir}/error.log"
      cmd << "--init-file=#{@initfile}" if @initfile != nil
      cmd << "&"

      mysql_daemon = fork do
        exec cmd.join(' ')
      end

      Process.detach(mysql_daemon)
    end
  end
end
