$(window).load(function() {
    if (document.body && document.body.offsetWidth) {
      var initWidth = document.body.offsetWidth;
    }
    if (document.compatMode=='CSS1Compat' && document.documentElement && document.documentElement.offsetWidth) {
      var initWidth = document.documentElement.offsetWidth;
    }
    if (window.innerWidth) {
      var initWidth = window.innerWidth;
    }
    var onHome = false;
    if ($('.home').length) {
      onHome = true;
    }
    var onPortfolio = false;
    if ($('.portfolio').length) {
      onPortfolio = true;
    }
    var onAbout = false;
    if ($('.about').length) {
      onAbout = true;
    }

    if (onHome && initWidth >= 600 && initWidth < 720) {
        $('.home > section').isotope();
    } else if (onHome && initWidth >= 720) {
        $('.home > section').isotope({ layoutMode: 'fitRows' });
    }

    if (onPortfolio && initWidth >= 320) {
        $('.portfolio > section ul').isotope({ layoutMode: 'fitRows' });
    }
  
    if (onAbout) {
      var container = $('section');
      if (container.width() >= 600) {
        container.isotope({ resizable: false, masonry: { columnWidth: container.width() / 2 }});
      }
    }

    $(window).smartresize(function() {
      
    });

});

$(window).smartresize(function() {
    if (document.body && document.body.offsetWidth) {
      var initWidth = document.body.offsetWidth;
    }
    if (document.compatMode=='CSS1Compat' && document.documentElement && document.documentElement.offsetWidth) {
      var initWidth = document.documentElement.offsetWidth;
    }
    if (window.innerWidth) {
      var initWidth = window.innerWidth;
    }
    var onHome = false;
    if ($('.home').length) {
      onHome = true;
    }
    var onPortfolio = false;
    if ($('.portfolio').length) {
      onPortfolio = true;
    }
    var onAbout = false;
    if ($('.about').length) {
      onAbout = true;
      var container = $('section');
    }

    if (onHome && initWidth >= 600 && initWidth < 720) {
        $('.home > section').isotope({layoutMode: 'masonry'});
    } else if (onHome && initWidth < 600) {
        $('.home > section').isotope({layoutMode: 'straightDown'});
    } else if (onHome) {
        $('.home > section').isotope({layoutMode: 'fitRows'});
    }

    if (onPortfolio && initWidth >= 320) {
        $('.portfolio > section ul').isotope({ layoutMode: 'fitRows' });
    } else if (onPortfolio) {
        $('.portfolio > section ul').isotope({ layoutMode: 'straightDown' });
    }

    if (onAbout && container.width() >= 600) {
      container.isotope({resizable: false, layoutMode: 'masonry', masonry: { columnWidth: container.width() / 2 }});
    } else if (onAbout) {
      container.isotope({resizable: false, layoutMode: 'straightDown'});
    }
});
