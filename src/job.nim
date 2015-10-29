import future, tables, sequtils
import sdl2
import entity, sprite, physics, controller, skill, common_types, util

type
  Jobs* = enum
    Fighter
    Mage
  Job* = ref object of RootObj
    name: string
    skills: Table[string, Skill]
  Character = ref object of RootObj
    entity*: Entity
    life: int
    energy: int
    job: Job

proc allJobs*(ren: RendererPtr): Table[Jobs, Job] =
  let allSkills = allSkills(ren)
  return toTable({
    Fighter: Job(
      name: "Fighter",
      skills: initTable[string, Skill]()
    ),
    Mage: Job(
      name: "Mage",
      skills: allSkills.filterTableByKey(
        proc(skillName: string): bool =
          return skillName in ["fireball"]
      )
    )
  })

proc newCharacter*(
  entity: Entity,
  ren: RendererPtr,
  job: Jobs
): Character =
  return Character(
    entity: entity,
    life: 100,
    energy: 100,
    job: allJobs(ren)[job]
  )

method useSkill*(user: Character, skillName: string): Entity =
  let skill = user.job.skills[skillName]
  case skill.action:
  of Projectile:
    result = skill.entityGenerator(user.entity.getBody.rect)
