package controllers

import (
	"net/http"
	"time"
    gwsRouter "github.com/oskarszura/trips/gowebserver/router"
)

func AuthenticateLogout(w http.ResponseWriter, r *http.Request, options gwsRouter.UrlOptions) {
	cookie := http.Cookie {
		Path: "/",
		Name: "sid",
		Expires: time.Now().Add(-100 * time.Hour),
		MaxAge: -1 }

	http.SetCookie(w, &cookie)

	http.Redirect(w, r, "/", http.StatusSeeOther)
}
