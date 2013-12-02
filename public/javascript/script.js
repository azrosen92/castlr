$(window).load(function() {

  var map;
  var castle_data;
  var regex = new RegExp("[\\?&]castle=([^&#]*)");
  console.log(location.search);
  var country = regex.exec(location.search)[1];

  function initialize() {
    console.log('going to ' + country);
    console.log('=======================');
    console.log('requesting data for ' + country + '...');
    request_data_for(country); 
  }

  initialize();
  
  
});

function request_data_for(country) {
  $.ajax({
      type:'GET',
      url: '/map/'+country,
      crossDomain: true,
      dataType: 'json',
      success: function(data) {
        castle_data = data;
        console.log("computing centroid...");
        console.log("========================");
        var cntrLatLng = compute_centroid(castle_data);
        console.log(cntrLatLng);
        var mapOptions = {
          center: cntrLatLng,          
          zoom: 6
        };

        map = new google.maps.Map(document.getElementById("map-container"),
          mapOptions);
        put_data_on_map(castle_data, map);

      }
    });
}

function compute_centroid(data) {
  console.log('computing centroid of...');
  console.log(data);
  total_sum_lat = 0;
  total_sum_lng = 0;
  total_num = 0;

  for (castle in data['info']) {
    if (data['info'][castle] != null) {
      castle_obj = data['info'][castle];
      console.log(castle);
      console.log("latitude:" + castle_obj['latitude']);
      console.log("lontitude:" + castle_obj['longitude']);
          
      total_num += 1;
      total_sum_lat += make_decimal(castle_obj['latitude']);
      total_sum_lng += make_decimal(castle_obj['longitude']);
      console.log("sum so far: " + total_sum_lat + "," + total_sum_lng);
      console.log("===========================");
    }
  }

  var ret_coor = new google.maps.LatLng(total_sum_lat/total_num, total_sum_lng/total_num);
  console.log('return coord ' + ret_coor);
  return ret_coor;
} 

function put_data_on_map(data, map) {
  var infoWindow = new google.maps.InfoWindow();
  
  for (castle in data['info']) {
    if (data['info'][castle] != null) {
      var lat_string = data['info'][castle]['latitude'];
      var lng_string = data['info'][castle]['longitude'];
      var img_url = data['info'][castle]['img_url'];

      var latlng = make_lat_lng(lat_string, lng_string);

      var marker = new google.maps.Marker({
        position: latlng,
        map: map,
        title: castle,
        icon: 'images/flag.png'
      });

      marker.content = make_info_window(data['info'][castle], castle);

      google.maps.event.addListener(marker, 'click', function() {
        infoWindow.setContent(this.content);
        infoWindow.open(this.getMap(), this);
      });

      marker.setAnimation(google.maps.Animation.DROP);
      marker.setMap(map);
    }
  }
}

function make_info_window(info, castle) {
  content_string = '<div id="info-window"><h3 id="title">' 
                + castle + '</h3><div id="image"><img src="'
                + info['img_url'] + '" /></div></div>';

  return content_string;  
}

function make_lat_lng(lat, lng) {
  return new google.maps.LatLng(make_decimal(lat), make_decimal(lng));
}

function make_decimal(str_val) {
  var mult = 1;
  var dir_reg = RegExp("[NSWE]");
  if (dir_reg.exec(str_val)[0] === 'S' || dir_reg.exec(str_val)[0] === 'W') {
    mult = -1;
  }
  var deg_reg = RegExp("[0-9]{1,}\u00B0");
  var hour_reg = RegExp("[0-9]{1,}\u2032");
  var min_reg = RegExp("[0-9]{1,}\u2033");

  var deg_results = deg_reg.exec(str_val);
  var hour_results = hour_reg.exec(str_val);
  var min_results = min_reg.exec(str_val);

  var deg_val = deg_results != null ? deg_results[0].slice(0,-1) : "0";
  var hour_val = hour_results != null ? hour_results[0].slice(0,-1) : "0";
  var min_val = min_results != null ? min_results[0].slice(0,-1) : "0";

  var dec_val = (parseInt(deg_val)
              + parseInt(hour_val)/60
              + parseInt(min_val)/3600) * mult;
  
  return dec_val;
}

