#!/usr/bin/env ruby
#
# Download latest full log to have it indexed
# 5 * * * * /usr/local/bin/download_rds_logs.rb

require 'rubygems'
require 'aws-sdk'
require 'logger'
require 'statsd'

def rds_pick_latest_log(rds, db, log_name_filter="slowquery")
  opts = {
    db_instance_identifier: db,
    filename_contains: log_name_filter,
  }
  all_logs = rds.describe_db_log_files(opts)
  all_logs_sorted = all_logs.describe_db_log_files.sort_by {|log| log.last_written}

  if all_logs_sorted.empty?
    $logger.info { "#{db}: no logs with mask \"#{log_name_filter}\" found, skipping." }
    return nil
  end

  # pick the last full log
  if all_logs_sorted.length >= 2
    latest_full_log = all_logs_sorted[-2].log_file_name
  else
    latest_full_log = all_logs_sorted[0].log_file_name
  end

  # pick a proper name for saved log
  latest_full_log_condensed = latest_full_log.match(/\/(.*)\.log/).captures.first
  out_log_file = "#{$log_path}/#{db}-#{latest_full_log_condensed}.log"

  return { latest_full_log: latest_full_log, out_log_file: out_log_file }
end

def rds_download_log(rds, db, latest_full_log, out_log_file)
  $logger.info { "#{db}: saving #{latest_full_log} to #{out_log_file}" }
  opts = {
    db_instance_identifier: db,
    log_file_name: latest_full_log,
    number_of_lines: 60000,
    marker: "0"
  }
  additional_data_pending = true
  File.open(out_log_file, "wb+") do |file|
    while additional_data_pending do
      out = rds.download_db_log_file_portion(opts)
      file.write(out[:log_file_data])
      opts[:marker] = out[:marker]
      additional_data_pending = out[:additional_data_pending]
    end
  end
end

begin
  $statsd = Statsd.new

  $log_path = '/var/log/rds'
  basename = File.basename($0, File.extname($0)) 
  logfile = File.open("#{$log_path}/#{basename}.log", 'w+')
  $logger = Logger.new(logfile)
  $logger.progname = basename

  $logger.info { "Fetching RDS logs..."}
  # TODO: expand to more regions
  rds = Aws::RDS::Client.new(region: 'us-east-1') # credentials from ~/.aws/credentials
  instances = rds.describe_db_instances
  instances.db_instances.each do |instance|
    db = instance.db_instance_identifier
    $logger.info { "Processing #{db}" }
    # TODO: autodetect log types
    log = rds_pick_latest_log(rds, db, "slowquery")
    rds_download_log(rds, db, log[:latest_full_log], log[:out_log_file]) unless log.nil?
    log = rds_pick_latest_log(rds, db, "error")
    rds_download_log(rds, db, log[:latest_full_log], log[:out_log_file]) unless log.nil?
  end
rescue => e
  # report to datadog
  $statsd.gauge('download.rds.logs.status', 1) if $statsd
  # log it
  $logger.error e if $logger
  # send error by email
  raise e
end

$statsd.gauge('download.rds.logs.status', 0)
$logger.info { "Done."}
