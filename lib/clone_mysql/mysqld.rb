module CloneMysql

  class Mysqld
    def initialize(datadir,port=3306,pidfile='/var/run/mysql_clone.pid',defaults_file='/etc/mysql_clone.cnf',initfile=nil)
      @datadir = datadir
      @port = port
      @pidfile = pidfile
      @initfile = initfile
      @defaults_file = defaults_file
    end

    def is_main_mysqld_running?
      pid = File.open('/var/mysql/mysql.pid').read.strip().to_i
      begin
        Process.getpgid(pid)
        true
      rescue Errno::ESRCH
        false
      end
    end

    def start_mysqld()
      if is_main_mysqld_running?
        exit_now!("The Mysqld service is running please, svcadm disable mysql, first")
      end

      cmd = []
      cmd << "/opt/local/libexec/mysqld"
      cmd << "--user=mysql"
      cmd << "--basedir=/opt/local"
      cmd << "--datadir=#{@datadir}"
      cmd << "--pidfile=#{@pidfile}"
      cmd << "--port=#{@port}"
      cmd << "--skip-slave-start"
      cmd << "--defaults-file"
      cmd << "--log-error=/var/log/mysql/#{@datadir}-error.log"
      cmd << "--init-file=#{@initfile}" if @initfile != nil
      cmd << "&"

      mysql_daemon = fork do
        exec cmd.join(' ')
      end

      Process.detach(mysql_daemon)
    end
  end
end
