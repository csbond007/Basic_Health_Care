package com.cassandra.phantom.modeling.main

import com.cassandra.phantom.modeling.connector.Connector
import com.cassandra.phantom.modeling.database.ProductionDatabase
import com.cassandra.phantom.modeling.entity.Song
import com.cassandra.phantom.modeling.service.SongsService
import com.datastax.driver.core.utils.UUIDs
import com.websudos.phantom.reactivestreams._

object CassandraConnecter {
  def main(args: Array[String]) {
    //saveOrUpdate 
    SongsService.saveOrUpdate(Song(UUIDs.timeBased(), "Jai Ho!", "slumdog millionaire", "A R Rahman"))
    
    //getSongsByArtist
    val song = SongsService.getSongsByArtist("A R Rahman")
  }
}