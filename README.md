# Better Bodies
Makes ragdolls stick around longer

## TODO

- [ ] Resolve issue where >44 ragdolls results in no collision
- [ ] Add configuration .ini and values into configure mutator menu
- [ ] Refactor code
- [ ] Add gibbing of ragdolls based on Aspide's mutator (https://unrealarchive.org/unreal-tournament-2004/mutators/G/gibable-corpses-v5_52b89593.html)

## > 44 ragdolls no collision
In `ExtendedRagdollMutator.uc`, I have `MaxRagdollsModded=44`. This is written to `Level.MaxRagdolls` in `PostBeginPlay()`

There are three courses. 
1. If we leave the `KMakeRagdollAvailable()` function and have a limit of 44 or fewer ragdolls, then the oldest ragdolls lose their karam collisions (due to being frozen in the engine code) and are removed, allowing for the newest ragdolls to have collision.
2. If we comment out the `KMakeRagdollAvailable()` function, or we have a limit above 44 ragdolls and also comment out the `KIsRagdollAvailable() check, then the newest ragdolls have no karma collisions and fall through the floor map immediately.
3. If we comment out the `KMakeRagdollAvailable()` function, keep the limit of 44 or fewer ragdolls, but we also leave the check for available ragdolls, then it skips the creation of a ragdoll and instead plays a non-karma animation, in which case there appears to be no limit.

4. It appears ther is no limit on the maximum number of gibs either, although they also seem to have collision enabled it may be because they are turned into static objects after some small time.
5. 
From `ExtendedRagdollPawn.uc` ~line 41
```
if( RagSkelName != "" )
{
    KMakeRagdollAvailable();
}

if( KIsRagdollAvailable() && RagSkelName != "" )
// if(RagSkelName != "" )
{
   ... karma initialization stuff
}
```
  
## Configuration .ini and values into configure mutator menu

## Refactor code

## Add gibbing of ragdolls
