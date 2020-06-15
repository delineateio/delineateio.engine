package data

import (
	"errors"
	"strings"
	"time"

	"github.com/avast/retry-go"
	"github.com/jinzhu/gorm"

	c "github.com/delineateio/core/config"
	l "github.com/delineateio/core/logging"

	// Used internally by gorm to load the postgres driver
	_ "github.com/jinzhu/gorm/dialects/postgres"
	_ "github.com/lib/pq"
)

// DefaultDBType is the default db type
const DefaultDBType = "postgres"

// IRepository for all repositories
type IRepository interface {
	Open() error
	Migrate() error
	Close() error
}

// Repository that reprents the access to the underlying database
type Repository struct {
	Name                  string
	Database              *gorm.DB
	DBTypeKey             string
	DBConnectionStringKey string
	AllowedDBTypes        []string
	DefaultDBType         string
	Attempts              uint // Number of attempts
	Delay                 time.Duration
	MaxIdle               int
	MaxOpen               int
	MaxLifetime           time.Duration
	SetDBFunc             func() (*gorm.DB, error)
	Info                  Info
}

// Info represents the connection details
type Info struct {
	Type             string
	ConnectionString string
	Tries            int // Actual attempts
}

// NewRepository returns production database access
func NewRepository(name string) *Repository {

	return &Repository{
		Name:                  name,
		DBTypeKey:             "db." + name + ".type",
		DBConnectionStringKey: "db." + name + ".connection",
		AllowedDBTypes:        []string{"postgres"},
		DefaultDBType:         DefaultDBType,
		Attempts:              c.GetUint("db."+name+".retries.attempts", 3),
		Delay:                 c.GetDuration("db."+name+".retries.delay", 500*time.Millisecond),
		MaxIdle:               c.GetInt("db."+name+".limits.maxIdle", 10),
		MaxOpen:               c.GetInt("db."+name+".limits.maxOpen", 50),
		MaxLifetime:           c.GetDuration("db."+name+".limits.maxLifetime", 60*time.Minute),
	}
}

// Default to postgres
// Get the connection string
// Get a value not in approved list (error)

func (r *Repository) dbTypeAllowed(expect string, list []string) bool {
	for _, current := range list {
		if strings.EqualFold(expect, current) {
			return true
		}
	}
	return false
}

func (r *Repository) getDatabaseType() (string, error) {

	var err error
	dbType := c.GetString(r.DBTypeKey, DefaultDBType)

	if !r.dbTypeAllowed(dbType, r.AllowedDBTypes) {
		err = errors.New("no db type was provided")
		l.Error("db.connection.error", err)
		dbType = DefaultDBType
	}

	return dbType, err
}

func (r *Repository) getConnectionString() (string, error) {

	var err error
	// It's not really possible to default connection strings!
	connectionString := c.GetString(r.DBConnectionStringKey, "")

	if len(connectionString) == 0 {
		err = errors.New("no connection string was provided")
		l.Error("db.connection.error", err)
	}

	return connectionString, err
}

func (r *Repository) getInfo() (Info, error) {

	dbType, err := r.getDatabaseType()
	if err != nil {
		return Info{}, err
	}

	dbConnectionString, err := r.getConnectionString()
	if err != nil {
		return Info{}, err
	}

	l.Debug("db.connection", dbType+" - "+dbConnectionString)

	info := Info{
		Type:             dbType,
		ConnectionString: dbConnectionString,
		Tries:            0,
	}

	r.Info = info
	return info, nil
}

// Ping pings the underlying database to ensure it's contactable
func (r *Repository) Ping() error {

	info, err := r.getInfo()
	if err != nil {
		return err
	}

	// Ensures func set to open DB
	r.setDB(info)

	db, err := r.SetDBFunc()
	if err != nil {
		l.Error("db.connection", err)
		return err
	}

	return db.DB().Ping()
}

// Ensures that a func is set to open the DB
func (r *Repository) setDB(info Info) {

	// Enables the replacing of the underlying DB connection
	if r.SetDBFunc == nil {
		r.SetDBFunc = func() (*gorm.DB, error) {
			return gorm.Open(info.Type, info.ConnectionString)
		}
	}
}

// Open the database and sets the underlying configuration
func (r *Repository) Open() error {

	info, err := r.getInfo()
	if err != nil {
		return err
	}

	// Ensures func set to open DB
	r.setDB(info)

	err = retry.Do(
		func() error {
			r.Info.Tries = r.Info.Tries + 1
			r.Database, err = r.SetDBFunc()
			if err != nil {
				return err
			}
			// defer r.Database.Close()
			return nil
		},
		retry.Attempts(r.Attempts),
		retry.Delay(r.Delay),
	)
	if err != nil {
		l.Error("db.open.error", err)
		return err
	}

	// Sets the more advanced settings
	r.Database.DB().SetMaxOpenConns(r.MaxOpen)
	r.Database.DB().SetMaxIdleConns(r.MaxIdle)
	r.Database.DB().SetConnMaxLifetime(r.MaxLifetime)

	return nil
}

// Migrate placeholder for service specific migration
func (r *Repository) Migrate() error {

	err := errors.New("migrate is not implemneted in the base implemenation of respositor")
	l.Error("db.migrate.error", err)
	return err
}

// Close the DB connection
func (r *Repository) Close() error {

	err := r.Database.Close()
	if err != nil {
		l.Error("db.close.error", err)
		return err
	}

	return nil
}
