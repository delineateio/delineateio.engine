package server

import (
	"time"

	c "github.com/delineateio/core/config"
	"github.com/fvbock/endless"
)

// TimeOuts represents the server timeout config
type TimeOuts struct {
	Read   time.Duration
	Write  time.Duration
	Hammer time.Duration
}

func readTimeOuts() TimeOuts {

	return TimeOuts{
		Read:   c.GetDuration("server.timeouts.read", 5*time.Second),
		Write:  c.GetDuration("server.timeouts.write", 5*time.Second),
		Hammer: c.GetDuration("server.timeouts.hammer", time.Minute),
	}
}

func updateTimeOuts(timeOuts TimeOuts) {

	endless.DefaultReadTimeOut = timeOuts.Read
	endless.DefaultWriteTimeOut = timeOuts.Write
	endless.DefaultHammerTime = timeOuts.Hammer
}

func setTimeOuts() {

	updateTimeOuts(readTimeOuts())
}
