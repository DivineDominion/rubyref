# Times and Dates



## Time

Time is an abstraction of dates and times. Time is stored internally as
the number of seconds with fraction since the *Epoch*, January 1, 1970
00:00 UTC. Also see the library module Date. The Time class treats GMT
(Greenwich Mean Time) and UTC (Coordinated Universal Time) as
equivalent. GMT is the older way of referring to these baseline times
but persists in the names of calls on POSIX systems.

All times may have fraction. Be aware of this fact when comparing times
with each other -- times that are apparently equal when displayed may be
different when compared.

Since Ruby 1.9.2, Time implementation uses a signed 63 bit integer,
Bignum or Rational. The integer is a number of nanoseconds since the
*Epoch* which can represent 1823-11-12 to 2116-02-20. When Bignum or
Rational is used (before 1823, after 2116, under nanosecond), Time works
slower as when integer is used.

### Creating a new Time instance

You can create a new instance of Time with Time::new. This will use the
current system time. Time::now is an alias for this. You can also pass
parts of the time to Time::new such as year, month, minute, etc. When
you want to construct a time this way you must pass at least a year. If
you pass the year with nothing else time will default to January 1 of
that year at 00:00:00 with the current system timezone. Here are some
examples:


```ruby
Time.new(2002)         #=> 2002-01-01 00:00:00 -0500
Time.new(2002, 10)     #=> 2002-10-01 00:00:00 -0500
Time.new(2002, 10, 31) #=> 2002-10-31 00:00:00 -0500
Time.new(2002, 10, 31, 2, 2, 2, "+02:00") #=> 2002-10-31 02:02:02 +0200
```

You can also use `#gm`, `#local` and `#utc` to infer GMT, local and UTC
timezones instead of using the current system setting.

You can also create a new time using Time::at which takes the number of
seconds (or fraction of seconds) since the [Unix
Epoch](http://en.wikipedia.org/wiki/Unix_time).


```ruby
Time.at(628232400) #=> 1989-11-28 00:00:00 -0500
```

### Working with an instance of Time

Once you have an instance of Time there is a multitude of things you can
do with it. Below are some examples. For all of the following examples,
we will work on the assumption that you have done the following:


```ruby
t = Time.new(1993, 02, 24, 12, 0, 0, "+09:00")
```

Was that a monday?


```ruby
t.monday? #=> false
```

What year was that again?


```ruby
t.year #=> 1993
```

Was it daylight savings at the time?


```ruby
t.dst? #=> false
```

What's the day a year later?


```ruby
t + (60*60*24*365) #=> 1994-02-24 12:00:00 +0900
```

How many seconds was that since the Unix Epoch?


```ruby
t.to_i #=> 730522800
```

You can also do standard functions like compare two times.


```ruby
t1 = Time.new(2010)
t2 = Time.new(2011)

t1 == t2 #=> false
t1 == t1 #=> true
t1 <  t2 #=> true
t1 >  t2 #=> false

Time.new(2010,10,31).between?(t1, t2) #=> true
```

[Time Reference](http://ruby-doc.org/core-2.5.0/Time.html)



### time.rb

Part of useful functionality for `Time` is provided by standard library
`time`.



All examples assume you have loaded Time with:


```ruby
require 'time'
```

All of these examples were done using the EST timezone which is GMT-5.



#### Converting to a String


```ruby
t = Time.now
t.iso8601  # => "2011-10-05T22:26:12-04:00"
t.rfc2822  # => "Wed, 05 Oct 2011 22:26:12 -0400"
t.httpdate # => "Thu, 06 Oct 2011 02:26:12 GMT"
```



#### Time.parse

`#parse` takes a string representation of a Time and attempts to parse
it using a heuristic.


```ruby
Time.parse("2010-10-31") #=> 2010-10-31 00:00:00 -0500
```

Any missing pieces of the date are inferred based on the current date.


```ruby
# assuming the current date is "2011-10-31"
Time.parse("12:00") #=> 2011-10-31 12:00:00 -0500
```

We can change the date used to infer our missing elements by passing a
second object that responds to `#mon`, `#day` and `#year`, such as Date,
Time or DateTime. We can also use our own object.


```ruby
class MyDate
  attr_reader :mon, :day, :year

  def initialize(mon, day, year)
    @mon, @day, @year = mon, day, year
  end
end

d  = Date.parse("2010-10-28")
t  = Time.parse("2010-10-29")
dt = DateTime.parse("2010-10-30")
md = MyDate.new(10,31,2010)

Time.parse("12:00", d)  #=> 2010-10-28 12:00:00 -0500
Time.parse("12:00", t)  #=> 2010-10-29 12:00:00 -0500
Time.parse("12:00", dt) #=> 2010-10-30 12:00:00 -0500
Time.parse("12:00", md) #=> 2010-10-31 12:00:00 -0500
```

`#parse` also accepts an optional block. You can use this block to
specify how to handle the year component of the date. This is
specifically designed for handling two digit years. For example, if you
wanted to treat all two digit years prior to 70 as the year 2000+ you
could write this:


```ruby
Time.parse("01-10-31") {|year| year + (year < 70 ? 2000 : 1900)}
#=> 2001-10-31 00:00:00 -0500
Time.parse("70-10-31") {|year| year + (year < 70 ? 2000 : 1900)}
#=> 1970-10-31 00:00:00 -0500
```



#### Time.strptime

`#strptime` works similar to `parse` except that instead of using a
heuristic to detect the format of the input string, you provide a second
argument that describes the format of the string. For example:


```ruby
Time.strptime("2000-10-31", "%Y-%m-%d") #=> 2000-10-31 00:00:00 -0500
```

[Time
Reference](https://ruby-doc.org/stdlib-2.5.0/libdoc/time/rdoc/Time.html)



### Date

*Part of standard library. You need to `require 'date'` before using.*

A subclass of Object that includes the Comparable module and easily
handles date.

A Date object is created with Date::new, Date::jd, Date::ordinal,
Date::commercial, Date::parse, Date::strptime, Date::today,
`Time#to_date`, etc.


```ruby
require 'date'

Date.new(2001,2,3)
 #=> #<Date: 2001-02-03 ...>
Date.jd(2451944)
 #=> #<Date: 2001-02-03 ...>
Date.ordinal(2001,34)
 #=> #<Date: 2001-02-03 ...>
Date.commercial(2001,5,6)
 #=> #<Date: 2001-02-03 ...>
Date.parse('2001-02-03')
 #=> #<Date: 2001-02-03 ...>
Date.strptime('03-02-2001', '%d-%m-%Y')
 #=> #<Date: 2001-02-03 ...>
Time.new(2001,2,3).to_date
 #=> #<Date: 2001-02-03 ...>
```

All date objects are immutable; hence cannot modify themselves.

The concept of a date object can be represented as a tuple of the day
count, the offset and the day of calendar reform.

The day count denotes the absolute position of a temporal dimension. The
offset is relative adjustment, which determines decoded local time with
the day count. The day of calendar reform denotes the start day of the
new style. The old style of the West is the Julian calendar which was
adopted by Caesar. The new style is the Gregorian calendar, which is the
current civil calendar of many countries.

The day count is virtually the astronomical Julian day number. The
offset in this class is usually zero, and cannot be specified directly.

A Date object can be created with an optional argument, the day of
calendar reform as a Julian day number, which should be 2298874 to
2426355 or negative/positive infinity. The default value is
`Date::ITALY` (2299161=1582-10-15). See also sample/cal.rb.


```
$ ruby sample/cal.rb -c it 10 1582
    October 1582
 S  M Tu  W Th  F  S
    1  2  3  4 15 16
17 18 19 20 21 22 23
24 25 26 27 28 29 30
31

$ ruby sample/cal.rb -c gb  9 1752
   September 1752
 S  M Tu  W Th  F  S
       1  2 14 15 16
17 18 19 20 21 22 23
24 25 26 27 28 29 30
```

A Date object has various methods. See each reference.


```ruby
d = Date.parse('3rd Feb 2001')
                             #=> #<Date: 2001-02-03 ...>
d.year                       #=> 2001
d.mon                        #=> 2
d.mday                       #=> 3
d.wday                       #=> 6
d += 1                       #=> #<Date: 2001-02-04 ...>
d.strftime('%a %d %b %Y')    #=> "Sun 04 Feb 2001"
```

[Date
Reference](https://ruby-doc.org/stdlib-2.5.0/libdoc/date/rdoc/Date.html)



### DateTime

*Part of standard library. You need to `require 'date'` before using.*

A subclass of Date that easily handles date, hour, minute, second, and
offset.

DateTime does not consider any leap seconds, does not track any summer
time rules.

A DateTime object is created with DateTime::new, DateTime::jd,
DateTime::ordinal, DateTime::commercial, DateTime::parse,
DateTime::strptime, DateTime::now, `Time#to_datetime`, etc.


```ruby
require 'date'

DateTime.new(2001,2,3,4,5,6)
                    #=> #<DateTime: 2001-02-03T04:05:06+00:00 ...>
```

The last element of day, hour, minute, or second can be a fractional
number. The fractional number's precision is assumed at most nanosecond.


```ruby
DateTime.new(2001,2,3.5)
                    #=> #<DateTime: 2001-02-03T12:00:00+00:00 ...>
```

An optional argument, the offset, indicates the difference between the
local time and UTC. For example, `Rational(3,24)` represents ahead of 3
hours of UTC, `Rational(-5,24)` represents behind of 5 hours of UTC. The
offset should be -1 to +1, and its precision is assumed at most second.
The default value is zero (equals to UTC).


```ruby
DateTime.new(2001,2,3,4,5,6,Rational(3,24))
                    #=> #<DateTime: 2001-02-03T04:05:06+03:00 ...>
```

The offset also accepts string form:


```ruby
DateTime.new(2001,2,3,4,5,6,'+03:00')
                    #=> #<DateTime: 2001-02-03T04:05:06+03:00 ...>
```

An optional argument, the day of calendar reform (`start`), denotes a
Julian day number, which should be 2298874 to 2426355 or
negative/positive infinity. The default value is `Date::ITALY`
(2299161=1582-10-15).

A DateTime object has various methods. See each reference.


```ruby
d = DateTime.parse('3rd Feb 2001 04:05:06+03:30')
                    #=> #<DateTime: 2001-02-03T04:05:06+03:30 ...>
d.hour              #=> 4
d.min               #=> 5
d.sec               #=> 6
d.offset            #=> (7/48)
d.zone              #=> "+03:30"
d += Rational('1.5')
                    #=> #<DateTime: 2001-02-04%16:05:06+03:30 ...>
d = d.new_offset('+09:00')
                    #=> #<DateTime: 2001-02-04%21:35:06+09:00 ...>
d.strftime('%I:%M:%S %p')
                    #=> "09:35:06 PM"
d > DateTime.new(1999)
                    #=> true
```

#### When should you use DateTime and when should you use Time?

It's a common misconception that [William
Shakespeare](http://en.wikipedia.org/wiki/William_Shakespeare) and
[Miguel de Cervantes](http://en.wikipedia.org/wiki/Miguel_de_Cervantes)
died on the same day in history - so much so that UNESCO named April 23
as [World Book Day because of this
fact](http://en.wikipedia.org/wiki/World_Book_Day). However, because
England hadn't yet adopted the [Gregorian Calendar
Reform](http://en.wikipedia.org/wiki/Gregorian_calendar#Gregorian_reform)
(and wouldn't until
[1752](http://en.wikipedia.org/wiki/Calendar_(New_Style)_Act_1750))
their deaths are actually 10 days apart. Since Ruby's Time class
implements a [proleptic Gregorian
calendar](http://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar) and
has no concept of calendar reform there's no way to express this with
Time objects. This is where DateTime steps in:


```ruby
shakespeare = DateTime.iso8601('1616-04-23', Date::ENGLAND)
 #=> Tue, 23 Apr 1616 00:00:00 +0000
cervantes = DateTime.iso8601('1616-04-23', Date::ITALY)
 #=> Sat, 23 Apr 1616 00:00:00 +0000
```

Already you can see something is weird - the days of the week are
different. Taking this further:


```ruby
cervantes == shakespeare
 #=> false
(shakespeare - cervantes).to_i
 #=> 10
```

This shows that in fact they died 10 days apart (in reality 11 days
since Cervantes died a day earlier but was buried on the 23rd). We can
see the actual date of Shakespeare's death by using the `#gregorian`
method to convert it:


```ruby
shakespeare.gregorian
 #=> Tue, 03 May 1616 00:00:00 +0000
```

So there's an argument that all the celebrations that take place on the
23rd April in Stratford-upon-Avon are actually the wrong date since
England is now using the Gregorian calendar. You can see why when we
transition across the reform date boundary:


```ruby
# start off with the anniversary of Shakespeare's birth in 1751
shakespeare = DateTime.iso8601('1751-04-23', Date::ENGLAND)
 #=> Tue, 23 Apr 1751 00:00:00 +0000

# add 366 days since 1752 is a leap year and April 23 is after February 29
shakespeare + 366
 #=> Thu, 23 Apr 1752 00:00:00 +0000

# add another 365 days to take us to the anniversary in 1753
shakespeare + 366 + 365
 #=> Fri, 04 May 1753 00:00:00 +0000
```

As you can see, if we're accurately tracking the number of [solar
years](http://en.wikipedia.org/wiki/Tropical_year) since Shakespeare's
birthday then the correct anniversary date would be the 4th May and not
the 23rd April.

So when should you use DateTime in Ruby and when should you use Time?
Almost certainly you'll want to use Time since your app is probably
dealing with current dates and times. However, if you need to deal with
dates and times in a historical context you'll want to use DateTime to
avoid making the same mistakes as UNESCO. If you also have to deal with
timezones then best of luck - just bear in mind that you'll probably be
dealing with [local solar
times](http://en.wikipedia.org/wiki/Solar_time), since it wasn't until
the 19th century that the introduction of the railways necessitated the
need for [Standard
Time](http://en.wikipedia.org/wiki/Standard_time#Great_Britain) and
eventually timezones.

[DateTime
Reference](https://ruby-doc.org/stdlib-2.5.0/libdoc/date/rdoc/DateTime.html)
