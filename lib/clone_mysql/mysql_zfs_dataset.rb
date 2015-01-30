class MySQLZFSDataset

  # Initialise with a snapshot of mysql data set
  # oppinionated we expect a mysql data set to also have a child
  # dataset named logs.
  def initialize(dataset)
    @dataset = ZFS(dataset)
  end

  def to_s
    @dataset.name
  end

  def mounted?(dataset)
    @dataset.mounted?
  end

  # Returns dataset name currently mounted at "path"
  # or nil
  def self.dataset_mounted_at(path)
    pool = ZFS('zones')
    dataset = nil
    dataset = pool.children(recursive: true).select { |fs| fs.mountpoint.to_s == path }.first
    if dataset == nil
      return nil
    end
    return dataset.name
  end

  def self.unmount(path)
    ZFS(path).mountpoint='none'
  end

  def self.mount(dataset, path)
    ZFS(dataset).mountpoint=path
  end

  def self.readonly(dataset, setting)
    ZFS(dataset).readonly = setting
  end

  def exist?(dataset)
    @dataset.exist?
  end

  # Does our snapshot's dataset, have a logs dataset also.
  def has_logs_dataset?
    @dataset.parent.children.include?(ZFS(@dataset.parent.name + "/logs"))
  end

  def find_logs_snapshot()
    snapname = @dataset.name.split('@')[1]
    @dataset.parent.children[0].snapshots.each do |s|
      if s.name.split('@')[1] == snapname
        return s
      end
    end
  end

  def clone_to(dest_dataset)
    if @dataset.type == :snapshot
      if ZFS(dest_dataset) != nil && ZFS(dest_dataset).exist?
        raise ArgumentError, "Clone dataset already exists"
      end

      # Do we have a logs dataset also
      if has_logs_dataset?
        puts("Cloning to #{dest_dataset}")
        @dataset.clone!(dest_dataset)
        logs_snapshot = find_logs_snapshot()
        logs_snapshot.clone!(dest_dataset + "/logs")
      else
        raise ArgumentError, "Could not find a child logs dataset ie mysql/logs, is this a mysql dataset?"
      end

    else
      raise ArgumentError, "Snapshot does not exist"
    end
  end
end

