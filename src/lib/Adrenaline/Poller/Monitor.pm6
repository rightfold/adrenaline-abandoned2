unit module Adrenaline::Poller::Monitor;

role Object is export(:Object) {}

class Ping does Object is export(:Ping) {
    has Str      $.host;
    has Duration $.timeout;
}
