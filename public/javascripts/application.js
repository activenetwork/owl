// Called when the browser is resized to resize each of the slides in the compact dashboard view
function resizePanels() {
  var watches = $$('.watch');
  var container_margin = $('sites').getStyle('marginLeft').match(/\d+/);  // how much space we need to reserve for the margins of the page
  var browser_width = parseInt(document.viewport.getWidth());             // browser width
  var watch_margin = parseInt(watches.first().up().getStyle('marginRight').match(/\d+/));  // how much margin for each watch
  var watch_min_width = parseInt(watches.first().getStyle('minWidth').match(/\d+/));  // the minimum width a watch is allowed to be
  var i = watches.length;
  
  // start counting backwards through the number of total watches until we find a width for each that is greater than the max width
  do {
    var watch_width = figureWatchWidth(browser_width, i, watch_margin, container_margin);  // how wide one slide should be
    i--;
  } while (watch_width < watch_min_width)

  // resize each slide
  watches.each(function(element) {
    //element.setStyle({'width':watch_width+'px'});
    element.up().setStyle({'width':watch_width+'px'});
    resizeLink(element, watch_width);
    resizeName(element, watch_width);
  });
  
}

// resizes the link in a watch so it doesn't wrap
function resizeLink(element, width) {
  var url = element.down('span.full_url').innerHTML.replace(/https?:\/\//,'');
  var a = element.down('span.url a');
  var font_size = a.getStyle('fontSize').replace(/px/,'');
  a.update(resizeText(url, font_size, width, 1.7, 'middle'));
}


function resizeName(element, width) {
  var full_name = element.down('span.full_name').innerHTML;
  var name = element.down('span.name');
  var font_size = name.getStyle('fontSize').replace(/px/,'');
  name.update(resizeText(full_name, font_size, width, 1.4, 'end'));
}


// Resizes a block of text based on a certain element size
// text => the text to resize
// font_size  => the size of the current font
// width => how wide of a space the font needs to fit
// font_factor => multiplier that compensates for font width (something like 1.5)
// shorten_at => where to shorten the text (and replace with ellipsis) - start, middle, end
function resizeText(text, font_size, width, font_factor, shorten_at) {
  var chars = width / font_size * font_factor;
  if (text.length > chars) {
    switch (shorten_at) {
    case 'start':
      return '...' + text.slice(-1,-chars);
      break;
    case 'middle':
      return text.slice(0,(chars/2)) + '...' + text.slice(-(chars/2));      // shorten the URL if it's too long, removing http:// at the beginning
      break;
    case 'end':
      return text.slice(0,chars) + '...';
      break;
    }
  } else {
    return text
  }
}


// computes how wide one slide should be
function figureWatchWidth(browser_width,total,watch_margin,container_margin) {
  return (browser_width / total - watch_margin) - (container_margin /total);  // how wide one slide should be
}

// reads cookies
function getCookie(c_name) {
  if (document.cookie.length>0) {
    c_start=document.cookie.indexOf(c_name + "=");
    if (c_start!=-1) {
      c_start=c_start + c_name.length+1;
      c_end=document.cookie.indexOf(";",c_start);
      if (c_end==-1) c_end=document.cookie.length;
      return unescape(document.cookie.substring(c_start,c_end));
    }
  }
  return "";
}

// methods used by watches
watchBlock = {
  
  server_range:$R(25,120),
  colors:{ fast:new Color('2c8428'),
           slow:new Color('eebd4e') },
  
  // set graphs to cookie settings
  setGraphsFromCookie:function() {
    cookies = []
    document.cookie.split(';').each(function(cookie) {
      var key = cookie.split('=').first();
      var value = unescape(cookie.split('=').last());
      values = $H(value.evalJSON());
      values.each(function(pair) {
        var obj = $("watch_"+pair.key+"_"+pair.value);
        if (obj) {
          $("watch_"+pair.key+"_"+pair.value).addClassName('current');
        }
      });
    });
  },
  
  // changes the little graph image in a watch
  changeGraph:function(item, id, type) {
    var element = $("watch_"+id+"_graph");
    element.up().down().childElements().each(function(el) { el.removeClassName('current') });
    $(item).up().addClassName('current');
    element.src = "/watches/response_graph/"+id+"?type="+type+"&"+Date.now();
  },
  
  // updates a watch with new data from the server
  update:function(watches) {
    watches.each(function(w) {
      var watch = w.watch
      var container = $('watch_'+watch.id);
      if (container) { 
        this.updateWatch(container, watch);
      }
    }.bind(this));
  },
  
  
  // update the contents of watch
  updateWatch:function(obj,data) {

    // update text labels and times
    obj.down('span.full_name').update(data.name);
    obj.down('span.full_url').update(data.url);
    
    obj.down('span.since_date').update(data.since);
    obj.down('span.since_title').update(data.status.name+' for ');
    obj.down('span.since_text').update(DateHelper.time_ago_in_words_with_parsing(data.since));
    
    obj.title = data.status_reason
    
    if (obj.down('span.enable')) {
      obj.down('span.enable').removeClassName('enable').addClassName('response');
    }
    if (obj.down('span.response')) {
      obj.down('span.response').update(data.last_response_time + ' ms');
    }
    if (obj.down('img.graph')) {
      obj.down('img.graph').src = '/watches/response_graph/'+data.id+'?'+Date.now();
    }

    // call resize panels so if the name or URL is too long, it'll get resized right now
    resizeLink(obj,obj.getWidth());
    resizeName(obj,obj.getWidth());
    
    // change color based on watch.from_average value. from_average represents a percentage of the average response
    // time for the last hour. So if from_average is 75, that means that ping was 75% of the speed of the average, so
    // it was _slower_ than the average by 25%. 110 would be 10% faster than the average
    var new_color = this.calculateColor(data.from_average);
    
    ['up','down','disabled','unknown'].each(function(class_name) {
      obj.removeClassName(class_name);
    });
    obj.addClassName(data.status.css);
  
    // figure out what color to morph this thing to
    switch (data.status.css) {
    case 'up':
      var new_color = this.calculateColor(data.from_average);
      break;
    case 'down':
      var new_color = new Color('921C1C');
      break;
    case 'disabled':
      var new_color = new Color('aaaaaa');
      break;
    case 'unknown':
      var new_color = new Color('666666');
      break;
    }

    obj.morph('background-color: #'+new_color.hex_color);
    
    // pulsate the watch if its response time is greater than the preset limit
    if (data.warning_time && data.last_response_time > data.warning_time) {
      new Effect.Pulsate(obj,{'delay':1});
    }
  }, 
  
  // converts from the server's range to a 0 - 100 scale
  convertRange:function(percent) {
    // anything outside the nominal server range is clipped to the min or max
    if (percent < this.server_range.start) {
      percent = this.server_range.start;
    } else if (percent > this.server_range.end) {
      percent = this.server_range.end;
    }
    var out = Math.floor(100 - (((percent - this.server_range.end) / (this.server_range.start - this.server_range.end)) * (100 - 0) + 0))
    //console.info('100 - (((%i - %i) / (%i - %i)) * (100 - 1) + 1) = %i', percent, this.server_range.end, this.server_range.start, this.server_range.end, out)
    return out
  },

  // calculates a color a point between color.fast and color.slow depending on the value of watch.from_average (higher number is faster)
  calculateColor:function(num) {
    var percent = this.convertRange(num);
    var new_r = this.colors.slow.r + Math.floor((this.colors.fast.r - this.colors.slow.r) * (percent / 100));
    var new_g = this.colors.slow.g + Math.floor((this.colors.fast.g - this.colors.slow.g) * (percent / 100));
    var new_b = this.colors.slow.b + Math.floor((this.colors.fast.b - this.colors.slow.b) * (percent / 100));
    var new_hex_color = parseInt(new_r).toString(16) + parseInt(new_g).toString(16) + parseInt(new_b).toString(16);
    return new Color(new_hex_color);
  }
  
}

function Color(hex_color) {
  this.r = parseInt(hex_color.slice(0,2),16);
  this.g = parseInt(hex_color.slice(2,4),16);
  this.b = parseInt(hex_color.slice(4,6),16);
  this.hex_color = this.r.toString(16) + this.g.toString(16) + this.b.toString(16);
}

// DateHelper from http://gist.github.com/58761 with a couple mods to display number of seconds
// gets us nicely formatted time spans (ie: 3 minutes ago)

var DateHelper = {
  // Takes the format of "Thu Jul 23 17:44:00 PDT 2009" and converts it to a relative time
  // Ruby strftime: %a %b %d %H:%M:%S %Z %Y
  time_ago_in_words_with_parsing: function(from) {
    var date = new Date;
    date.setTime(Date.parse(from)); 
    return this.time_ago_in_words(date);
  },
  
  time_ago_in_words: function(from) {
    return this.distance_of_time_in_words(new Date, from);
  },

  distance_of_time_in_words: function(to, from) {
    var distance_in_seconds = ((to - from) / 1000).floor();
    var distance_in_minutes = (distance_in_seconds / 60).floor();

    if (distance_in_minutes == 0) { return distance_in_seconds + ' seconds'; }
    if (distance_in_minutes == 1) { return 'a minute'; }
    if (distance_in_minutes < 45) { return distance_in_minutes + ' minutes'; }
    if (distance_in_minutes < 90) { return 'about 1 hour'; }
    if (distance_in_minutes < 1440) { return 'about ' + (distance_in_minutes / 60).floor() + ' hours'; }
    if (distance_in_minutes < 2880) { return '1 day'; }
    if (distance_in_minutes < 43200) { return (distance_in_minutes / 1440).floor() + ' days'; }
    if (distance_in_minutes < 86400) { return 'about 1 month'; }
    if (distance_in_minutes < 525960) { return (distance_in_minutes / 43200).floor() + ' months'; }
    if (distance_in_minutes < 1051199) { return 'about 1 year'; }

    return 'over ' + (distance_in_minutes / 525960).floor() + ' years';
  }
};