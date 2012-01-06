$(window).load(function() {
    var initWidth = window.innerWidth;
    var onHome = false;
    if ($('.home').length) {
      onHome = true;
    }
    var onPortfolio = false;
    if ($('.portfolio').length) {
      onPortfolio = true;
    }
    
    if (onHome && initWidth >= 600 && initWidth < 720) {
        $('.home > section').isotope();
    } else if (onHome && initWidth >= 720) {
        $('.home > section').isotope({ layoutMode: 'fitRows' });
    }

    if (onPortfolio && initWidth >= 320) {
        $('.portfolio > section ul').isotope({ layoutMode: 'fitRows' });
    }
});

$(window).smartresize(function() {
    var initWidth = window.innerWidth;
    var onHome = false;
    if ($('.home').length) {
      onHome = true;
    }
    var onPortfolio = false;
    if ($('.portfolio').length) {
      onPortfolio = true;
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
});
