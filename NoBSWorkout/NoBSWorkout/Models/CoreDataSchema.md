# Core Data Model Schema

## Instructions for Creating the Core Data Model in Xcode

1. In Xcode, create a new Data Model file: File → New → File → Data Model
2. Name it: `NoBSWorkout.xcdatamodeld`
3. Add the following entities and attributes as described below

## Entities

### ExerciseTemplate
**Codegen**: Class Definition

| Attribute | Type | Optional | Default | Indexed |
|-----------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| name | String | No | - | Yes |
| muscleGroup | String | Yes | - | Yes |
| category | String | Yes | - | Yes |
| isFavorite | Boolean | No | false | No |
| isCustom | Boolean | No | false | No |
| notes | String | Yes | - | No |
| createdDate | Date | No | - | No |

**Relationships**:
- `sets`: To-Many → SetEntry (Delete Rule: Cascade)
- `personalRecords`: To-Many → PersonalRecord (Delete Rule: Cascade)

---

### WorkoutSession
**Codegen**: Class Definition

| Attribute | Type | Optional | Default | Indexed |
|-----------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| date | Date | No | - | Yes |
| workoutType | String | No | - | Yes |
| startTime | Date | No | - | No |
| endTime | Date | Yes | - | No |
| notes | String | Yes | - | No |

**Relationships**:
- `sets`: To-Many → SetEntry (Delete Rule: Cascade)

---

### SetEntry
**Codegen**: Class Definition

| Attribute | Type | Optional | Default | Indexed |
|-----------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| setNumber | Integer 32 | No | 1 | No |
| weight | Double | No | 0 | No |
| reps | Integer 32 | No | 0 | No |
| rpe | Double | Yes | - | No |
| timestamp | Date | No | - | Yes |
| isPR | Boolean | No | false | Yes |

**Relationships**:
- `workoutSession`: To-One → WorkoutSession (Delete Rule: Nullify)
- `exercise`: To-One → ExerciseTemplate (Delete Rule: Nullify)

---

### PersonalRecord
**Codegen**: Class Definition

| Attribute | Type | Optional | Default | Indexed |
|-----------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| recordType | String | No | - | Yes |
| value | Double | No | 0 | No |
| reps | Integer 32 | Yes | - | No |
| dateAchieved | Date | No | - | Yes |
| setEntryId | UUID | Yes | - | No |

**Relationships**:
- `exercise`: To-One → ExerciseTemplate (Delete Rule: Nullify)

---

## Indexes

For performance, create composite indexes:

1. **SetEntry**: (exercise, timestamp) - for fetching recent sets per exercise
2. **WorkoutSession**: (date DESC) - for history list
3. **PersonalRecord**: (exercise, recordType) - for quick PR lookups

## Notes

- All `id` fields use UUID for uniqueness
- Date fields are indexed for efficient sorting/filtering
- Category and muscle group fields use String for flexibility (could be enum in future)
- Delete rules ensure cascade deletion (when exercise deleted, all sets/PRs deleted)
- isPR flag allows quick filtering for achievements
