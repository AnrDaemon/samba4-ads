#!/bin/sh
/usr/bin/mysql --defaults-extra-file=/etc/mysql/debian.cnf -e 'SELECT ( (
  @@key_buffer_size +
  @@innodb_buffer_pool_size +
  @@innodb_additional_mem_pool_size +
  @@innodb_log_buffer_size +
  @@max_tmp_tables * IF( @@tmp_table_size > @@max_heap_table_size , @@max_heap_table_size , @@tmp_table_size ) +
  @@query_cache_size +
  @@myisam_sort_buffer_size * 3 +
  @@max_connections * (
    @@read_buffer_size +
    @@join_buffer_size +
    @@read_rnd_buffer_size +
    @@thread_stack + (
      @@max_allowed_packet * 2
    )
  ) ) / 1024 / 1024 ) AS `maxmem`;'
