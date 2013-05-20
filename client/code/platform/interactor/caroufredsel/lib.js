

(function(){
// Store a reference to the original remove method.
    var originalHideMethod = jQuery.fn.hide;

// Define overriding method.
    jQuery.fn.hide = function(){
// Log the fact that we are calling our override.

        if (this[0]!=null && (this[0].id.indexOf("caroufredselimage")!=-1)) {
            console.log( "Override method:"+this[0].id );
            return this
// Execute the original method.
        } else {
            return originalHideMethod.apply( this, arguments );
        }
    }
})();