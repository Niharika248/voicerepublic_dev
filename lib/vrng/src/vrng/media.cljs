(ns vrng.media
  (:require
   [vrng.util :as u]
   [clojure.string :refer [replace]]
   [reagent.core :refer [atom]]))

(if js/audit (.log js/console "loading vrng.media"))

;; --- state

(defonce state (atom {:gesture-required false
                      :mode "none" ; streamed, static, or none
                      :duration 0
                      :offset 0
                      :paused true}))

;; --- private

(defn- streamed? []
  (= (@state :mode) "streamed"))

(defn- static? []
  (= (@state :mode) "static"))

(defn- audio-element
  "There has to be an audio tag with id audio in the page.

  https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement"
  []
  (u/element-by-id "audio"))

(defn- play-error-handler [error]
  (prn error)
  (swap! state assoc :gesture-required true))

;; http://diveintohtml5.info/everything.html
(defn can-play?
  "Checks if a given mimetype can be played by the browser."
  [mime]
  (not (empty? (and (.-canPlayType (audio-element))
                    (replace (.canPlayType (audio-element) mime) #"no" "")))))

(def ^:private formats
  [{:format "ogg" :mime "audio/ogg; codecs='vorbis'"}
   {:format "mp3" :mime "audio/mpeg;"}
   {:format "acc" :mime "audio/aac;"}
   ;;{:format "mp4" :mime "audio/mp4; codecs='mp4a.40.2'"}
   ;;{:format "m4a" :mime "audio/m4a;"}
   ;;{:format "wav" :mime "audio/wav; codecs='1'"}
   ])

(defn- can-play-reducer [result {:keys [format mime]}]
  (if (can-play? mime) (conj result format) result))

(defn supported-formats
  "Returns a vector of formats that the browser can play."
  []
  (reduce can-play-reducer [] formats))

(defn- supported-source
  "Appends the first supported format extension to the given url."
  [source]
  (str source "." (first (supported-formats))))

;; --- public getter

(defn gesture-required? []
  (:gesture-required @state))

(defn paused? []
  (.-paused (audio-element)))

(defn source []
  (.-currentSrc (audio-element)))

(defn current-runtime []
  (if (streamed?)
    (/ (+ (:offset @state) (:play-time @state)) 1000)
    (:current-time @state)))

(defn duration []
  (:duration @state))

(defn progress-percentage []
  (u/percentage (current-runtime) (duration)))

(defn volume-percentage []
  (str (* 100 (:volume @state)) "%"))

;; --- public setter

(defn source! [source]
  (let [url (if (streamed?) ; this shouldn't make a difference
              (supported-source source)
              source)]
    (prn "setting source to" url)
    ;;(.log js/console (streamed?) url)
    (aset (audio-element) "autoplay" "none")
    (aset (audio-element) "preload" "none")
    (aset (audio-element) "src" url)
    (aset (audio-element) "crossOrigin" "anonymous")))

(defn offset! [offset]
  (swap! state assoc :offset offset))

(defn volume! [volume]
  (swap! state assoc :volume volume)
  (aset (audio-element) "volume" volume))

(defn play! []
  (prn "playing...")
  (let [promise (.play (audio-element))]
    (.log js/console "play returned" promise)
    (if promise
      ;; if the play promise throws up^H^H an error...
      (.catch promise play-error-handler))))

(defn pause! []
  (.pause (audio-element)))

;; TODO seek should talk a value 0..1
(defn seek! [time]
  (aset (audio-element) "currentTime" time))

(defn mode! [mode]
  (swap! state assoc :mode mode))

(defn duration! [duration]
  (swap! state assoc :duration duration))

(defn on-playing! [callback]
  (swap! state assoc :on-playing callback))

;; --- updater

(def callback-timeout (* 1000 60)) ; 1 minute

(defn- update-state! []
  (if (audio-element)
    (if (paused?)
      (swap! state assoc :paused true)
      (do
        (swap! state assoc :gesture-required false)
        (swap! state assoc :duration (max (duration) (current-runtime)))
        (swap! state assoc :paused false)
        (swap! state update :play-time (partial + 250))
        (swap! state assoc :current-time (.-currentTime (audio-element)))
        (when-let [callback (:on-playing @state)]
          (when (= 0 (mod (:play-time @state) callback-timeout))
            (callback)))))))

(defonce updater (js/setInterval update-state! 250))


;; https://developer.mozilla.org/de/docs/Web/HTML/Element/audio
;; https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement
(defn debug-audio-comp []
  (let [element (.getElementById js/document "audio")]
    (if element
      [:table {:style {:font-size "70%"}}
       [:tr [:td "paused?"]               [:td (paused?)]]
       [:tr [:td "streamed?"]             [:td (streamed?)]]
       [:tr [:td "static?"]               [:td (static?)]]
       [:tr [:td "audio-element"]         [:td (str (audio-element))]]
       ;;[:tr [:td ""]           [:td ()]]
       ;;[:tr [:td ""]           [:td ()]]
       ;;[:tr [:td ""]           [:td ()]]
       ;;[:tr [:td ""]           [:td ()]]
       [:tr [:td "audioTracks"]           [:td (.-audioTracks element)]]
       [:tr [:td "autoplay"]              [:td (.-autoplay element)]]
       [:tr [:td "buffered"]              [:td (.-buffered element)]]
       [:tr [:td "controller"]            [:td (.-controller element)]]
       [:tr [:td "controls"]              [:td (.-controls element)]]
       [:tr [:td "crossOrigin"]           [:td (.-crossOrigin element)]]
       [:tr [:td "currentSrc"]            [:td (.-currentSrc element)]]
       [:tr [:td "currentTime"]           [:td (.-currentTime element)]]
       [:tr [:td "defaultMuted"]          [:td (.-defaultMuted element)]]
       [:tr [:td "defaultPlaybackRate"]   [:td (.-defaultPlaybackRate element)]]
       [:tr [:td "disableRemotePlayback"] [:td (.-disableRemotePlayback element)]]
       [:tr [:td "duration"]              [:td (.-duration element)]]
       [:tr [:td "ended"]                 [:td (.-ended element)]]
       [:tr [:td "error"]                 [:td (.-error element)]]
       [:tr [:td "initialTime"]           [:td (.-initialTime element)]]
       [:tr [:td "loop"]                  [:td (.-loop element)]]
       [:tr [:td "mediaGroup"]            [:td (.-mediaGroup element)]]
       ;;[:tr [:td "mediaKeys"]             [:td (.-mediaKeys element)]]
       ;;[:tr [:td "mozAudioCaptured"]      [:td (.-mozAudioCaptured element)]]
       ;;[:tr [:td "mozAudioChannelType"]   [:td (.-mozAudioChannelType element)]]
       ;;[:tr [:td "mozChannels"]           [:td (.-mozChannels element)]]
       ;;[:tr [:td "mozFragemntId"]         [:td (.-mozFragemntId element)]]
       ;;[:tr [:td "mozFrameBufferLength"]  [:td (.-mozFrameBufferLength element)]]
       ;;[:tr [:td "mozSampleRate"]         [:td (.-mozSampleRate element)]]
       [:tr [:td "muted"]                 [:td (.-muted element)]]
       [:tr [:td "networkState"]          [:td (.-networkState element)]]
       [:tr [:td "paused"]                [:td (.-paused element)]]
       [:tr [:td "playbackRate"]          [:td (.-playbackRate element)]]
       [:tr [:td "played"]                [:td (.-played element)]]
       [:tr [:td "preload"]               [:td (.-preload element)]]
       ;;[:tr [:td "preservesPitch"]        [:td (.-preservesPitch element)]]
       [:tr [:td "readyState"]            [:td (.-readyState element)]]
       [:tr [:td "seekable"]              [:td (.-seekable element)]]
       [:tr [:td "seeking"]               [:td (.-seeking element)]]
       ;;[:tr [:td "sinkId"]                [:td (.-sinkId element)]]
       [:tr [:td "src"]                   [:td (.-src element)]]
       [:tr [:td "srcObject"]             [:td (.-srcObject element)]]
       ;;[:tr [:td "textTracks"]            [:td (.-textTracks element)]]
       ;;[:tr [:td "videoTracks"]           [:td (.-videoTracks element)]]
       [:tr [:td "volume"]                [:td (.-volume element)]]
       ]
      [:span "no audio tag found"])))
