import Foundation
import SQLite3
public class TrackingDB: NSObject {
    enum SQLiteError: Error {
      case OpenDatabase(message: String)
      case Prepare(message: String)
      case Step(message: String)
      case Bind(message: String)
    }
    struct TrackingParam: Codable {
        let timestamp: Int64
        let heading: Float
        let lat: Double
        let lng: Double
        let speed: Double
        let driver: String
        let trackerId: String
        let jobStatus: Int
        let session: Int64
        let motionActivity: Int
    }
    private let dbPointer: OpaquePointer?
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    deinit {
        sqlite3_close(dbPointer)
    }
    
    var errorMessage: String {
      if let errorPointer = sqlite3_errmsg(dbPointer) {
          let errorMessage = String(cString: errorPointer)
          return errorMessage
      } else {
          return "No error message provided from sqlite."
      }
    }

    static func open() throws -> TrackingDB {
        let path = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("trackingDB.db")
        var db: OpaquePointer?
        if sqlite3_open_v2(path.path, &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
            return TrackingDB(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError
                    .OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }

    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil)
          == SQLITE_OK else {
        throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }

    let version = 2
    let createTableString = """
        CREATE TABLE IF NOT EXISTS ParamTracking(
        timestamp INTEGER PRIMARY KEY NOT NULL,
        heading REAL,
        lat REAL,
        lng REAL,
        speed REAL,
        driver TEXT,
        trackerId TEXT,
        jobStatus INTEGER,
        session INTEGER,
        motionActivity INTEGER)
        """
    func createTable() throws {
        if (SVTrackingSession.shared.dbVersion == 0) {
            // 1
            let createTableStatement = try prepareStatement(sql: createTableString)
            // 2
            defer {
                sqlite3_finalize(createTableStatement)
            }
            // 3
            guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
                throw SQLiteError.Step(message: errorMessage)
            }
            print("table created.")
            SVTrackingSession.shared.dbVersion = 1
            if (try checkColumnExist(column: "motionActivity")) {
                print("motionActivity column exists")
            } else {
                try addColumn()
            }
        } else if (SVTrackingSession.shared.dbVersion == 1) {
            if (try checkColumnExist(column: "motionActivity")) {
                print("motionActivity column exists")
            } else {
                try addColumn()
            }
        }
    }
    
    func checkColumnExist(column: String) throws -> Bool {
        let stmt = "SELECT " + column + " FROM ParamTracking"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, stmt, -1, &statement, nil)
          == SQLITE_OK else {
            return false;
        }
        return true;
    }
    
    func addColumn() throws{
        let stmt = "ALTER TABLE ParamTracking ADD COLUMN motionActivity INTEGER"
        let alterStatement = try prepareStatement(sql: stmt)
        defer {
            sqlite3_finalize(alterStatement)
        }
        guard sqlite3_step(alterStatement) == SQLITE_DONE else {
          throw SQLiteError.Step(message: errorMessage)
        }
        print("add column")
        SVTrackingSession.shared.dbVersion = version
    }
    
    func insertParam(param: TrackingParam)throws {
//        let insertStatementString = "INSERT INTO ParamTracking (timestamp, heading, lat, lng, speed, driver, trackerId, jobStatus, session) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);"
        let insertStatementString = "INSERT INTO ParamTracking (timestamp, heading, lat, lng, speed, driver, trackerId, jobStatus, session, motionActivity) VALUES (\(param.timestamp), \(param.heading), \(param.lat), \(param.lng), \(param.speed), '\(param.driver)', '\(param.trackerId)', \(param.jobStatus), \(param.session), \(param.motionActivity));"
        let insertStatement = try prepareStatement(sql: insertStatementString)
        defer {
          sqlite3_finalize(insertStatement)
        }
//        guard
//            sqlite3_bind_int64(insertStatement, 1, param.timestamp) == SQLITE_OK &&
//            sqlite3_bind_double(insertStatement, 2, Double(param.heading)) == SQLITE_OK &&
//            sqlite3_bind_double(insertStatement, 3, param.lat) == SQLITE_OK &&
//            sqlite3_bind_double(insertStatement, 4, param.lng) == SQLITE_OK &&
//            sqlite3_bind_double(insertStatement, 5, param.speed) == SQLITE_OK &&
//            sqlite3_bind_text(insertStatement, 6, param.driver, -1, nil) == SQLITE_OK &&
//            sqlite3_bind_text(insertStatement, 7, param.trackerId, -1, nil) == SQLITE_OK &&
//            sqlite3_bind_int(insertStatement, 8, Int32(param.jobStatus)) == SQLITE_OK &&
//            sqlite3_bind_int64(insertStatement, 9, param.session) == SQLITE_OK
//        else {
//            throw SQLiteError.Bind(message: errorMessage)
//        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
          throw SQLiteError.Step(message: errorMessage)
        }
        print("Successfully inserted row. \(param.driver)")
    }
    
    let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    func insertMulti(params: [TrackingParam]) {
        var insertStatement: OpaquePointer?
        let insertStatementString = "INSERT INTO ParamTracking (timestamp, heading, lat, lng, speed, driver, trackerId, jobStatus, session, motionActivity) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        if sqlite3_prepare_v2(
            dbPointer,
            insertStatementString,
            -1,
            &insertStatement,
            nil
        ) == SQLITE_OK {
            for param in params {
                sqlite3_bind_int64(insertStatement, 1, param.timestamp)
                sqlite3_bind_double(insertStatement, 2, Double(param.heading))
                sqlite3_bind_double(insertStatement, 3, param.lat)
                sqlite3_bind_double(insertStatement, 4, param.lng)
                sqlite3_bind_double(insertStatement, 5, param.speed)
                sqlite3_bind_text(insertStatement, 6, param.driver, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(insertStatement, 7, param.trackerId, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(insertStatement, 8, Int32(param.jobStatus))
                sqlite3_bind_int64(insertStatement, 9, param.session)
                sqlite3_bind_int(insertStatement, 10, Int32(param.motionActivity))
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted row.")
                } else {
                    print("Could not insert row.")
                }
                // 4
                sqlite3_reset(insertStatement)
            }
            sqlite3_finalize(insertStatement)
        } else {
        print("\nINSERT statement is not prepared.")
        }
    }
    
    public func insertMulti(params: [[String : Any]]) {
        var insertStatement: OpaquePointer?
        let insertStatementString = "INSERT INTO ParamTracking (timestamp, heading, lat, lng, speed, driver, trackerId, jobStatus, session, motionActivity) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        if sqlite3_prepare_v2(
            dbPointer,
            insertStatementString,
            -1,
            &insertStatement,
            nil
        ) == SQLITE_OK {
            for param in params {
                sqlite3_bind_int64(insertStatement, 1, param["timestamp"] as! Int64)
                sqlite3_bind_double(insertStatement, 2, param["heading"] as! Double)
                sqlite3_bind_double(insertStatement, 3, param["lat"] as! Double)
                sqlite3_bind_double(insertStatement, 4, param["lng"] as! Double)
                sqlite3_bind_double(insertStatement, 5, param["speed"] as! Double)
                sqlite3_bind_text(insertStatement, 6, param["driver"] as! String, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(insertStatement, 7, param["trackerId"] as! String, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(insertStatement, 8, param["jobStatus"] as! Int32)
                sqlite3_bind_int64(insertStatement, 9, param["session"] as! Int64)
                sqlite3_bind_int(insertStatement, 10, param["motionActivity"] as! Int32)
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted row. ")
                } else {
                    print("Could not insert row.")
                }
                // 4
                sqlite3_reset(insertStatement)
            }
            sqlite3_finalize(insertStatement)
        } else {
            print("\nINSERT statement is not prepared.")
        }
    }
    
    func getTrackingByUser(user: String) -> [[String : Any]]? {
        let querySql = "SELECT * FROM ParamTracking WHERE driver = '\(user)';"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
          return nil
        }
        defer {
          sqlite3_finalize(queryStatement)
        }
        var list : [[String : Any]] = []
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            var param : [String : Any] = [
                "timestamp": sqlite3_column_int64(queryStatement, 0),
                "heading": Float(sqlite3_column_double(queryStatement, 1)),
                "lat": sqlite3_column_double(queryStatement, 2),
                "lng": sqlite3_column_double(queryStatement, 3),
                "speed": sqlite3_column_double(queryStatement, 4),
                "driver": String(cString: sqlite3_column_text(queryStatement, 5)),
                "trackerId": String(cString: sqlite3_column_text(queryStatement, 6)),
                "jobStatus": Int(sqlite3_column_int(queryStatement, 7)),
                "session": sqlite3_column_int64(queryStatement, 8),
                "motionActivity": Int(sqlite3_column_int(queryStatement, 9)),
                "sourceType": "tracking-sdk"
            ]
            let motionActivity = param["motionActivity"] as? Int
            if (motionActivity != nil && motionActivity! < 0) {
                param.removeValue(forKey: "motionActivity")
            }
            list.append(param);
        }
        return list;
    }
    
    func getTrackingParamByUser(user: String) -> [TrackingParam]? {
        let querySql = "SELECT * FROM ParamTracking WHERE driver = '\(user)';"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
          return nil
        }
        defer {
          sqlite3_finalize(queryStatement)
        }
//        guard sqlite3_bind_text(queryStatement, 1, user, -1, nil) == SQLITE_OK else {
//          return nil
//        }
        var list : [TrackingParam] = []
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            let param = TrackingParam(
                timestamp: sqlite3_column_int64(queryStatement, 0),
                heading: Float(sqlite3_column_double(queryStatement, 1)),
                lat: sqlite3_column_double(queryStatement, 2),
                lng: sqlite3_column_double(queryStatement, 3),
                speed: sqlite3_column_double(queryStatement, 4),
                driver: String(cString: sqlite3_column_text(queryStatement, 5)),
                trackerId: String(cString: sqlite3_column_text(queryStatement, 6)),
                jobStatus: Int(sqlite3_column_int(queryStatement, 7)),
                session: sqlite3_column_int64(queryStatement, 8),
                motionActivity: Int(sqlite3_column_int(queryStatement, 9))
            )
            list.append(param);
        }
        return list;
    }
    
    func updateTrackerId(id: String, user: String) throws {
        let updateStatementString = "UPDATE ParamTracking SET trackerId = '\(id)' WHERE driver= '\(user)';"
        let queryStatement = try prepareStatement(sql: updateStatementString)
        defer {
          sqlite3_finalize(queryStatement)
        }
        guard sqlite3_step(queryStatement) == SQLITE_DONE else {
          throw SQLiteError.Step(message: errorMessage)
        }
        print("Successfully updated.")
    }
    
    func deleteBefore(user: String, time: Int64) throws {
        let deleteStatementString = "DELETE FROM ParamTracking WHERE driver='\(user)' AND timestamp <= \(time);"
        let queryStatement = try prepareStatement(sql: deleteStatementString)
        defer {
          sqlite3_finalize(queryStatement)
        }
        guard sqlite3_step(queryStatement) == SQLITE_DONE else {
          throw SQLiteError.Step(message: errorMessage)
        }
        print("Successfully deleted.")
    }
}
