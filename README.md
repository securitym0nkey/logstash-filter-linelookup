# Logstash Plugin for lookups via line based protocol

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is [MIT](LICENSE).


## Documentation
This filter plugin does simple lookups for enrichment via a line based protocol. A query(1 line) is send via a socket and a response(1 line) is received and stored at the *target* field.

The query is dynamicly build and can use *%{...}* style variables


### Configuration Options


|  Setting    |  Type  |  Required |
| ----------- | ------ | ----------|
| query       | string | yes       |
| target      | string | yes       |
| socket_path | string | yes       |



### Example config


```
filter {
 linelookup {
  query => "%{[source][ip]}"
  target => "[source][geo][name]"
  socket_path => "/var/run/lookup.sock"
 }
}

```
