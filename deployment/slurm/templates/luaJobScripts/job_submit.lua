--[[
 Example lua script demonstrating the Slurm job_submit/lua interface.
 This is only an example, not meant for use in its current form.
 For use, this script should be copied into a file name "job_submit.lua"
 in the same directory as the Slurm configuration file, slurm.conf.

202408 - 
               bwh_comppath-Interactive - for users who are members of BWH-COMPPATH-FULL-G
--]]


--[[
      Main calling functions
--]]


function slurm_job_submit(job_desc, part_list, submit_uid)
    local log_prefix = "slurm_job_submit"
    local interactive_partition = "bwh_comppath-Interactive"

    local basic_partition = "Basic"
    local short_partition = "Short"
    local medium_partition = "Medium"
    local long_partition = "Long"
    local mammoth_partition = "Mammoth"

    ESLURM_INVALID_GRES=2072

    -- check for interactive jobs (empty jobscripts)
    if (job_desc.script == nil or job_desc.script == '') then

        -- if the Basic, Short, Medium, Long, Mammoth or no partition is specified then default to bwh_comppath-Interactive
        if (job_desc.partition == nil or job_desc.partition == '' or 
             job_desc.partition == basic_partition or job_desc.partition == short_partition or 
             job_desc.partition == medium_partition or job_desc.partition == long_partition or
             job_desc.partition == mammoth_partition ) then
            job_desc.partition = interactive_partition
        end

    end 

    -- Check if gpu resources have been requested, if none redirect to eristwo/slurm

    if ( (job_desc.script ~= nil) and (job_desc.partition ~= "bwh_comppath") and 
         (job_desc.partition ~= "bwh_comppath-LONG") ) then

        -- For gpu=0 or undefined cancel the job

        if (job_desc.tres_per_job == nil or job_desc.tres_per_job == '') 
          then 
             slurm.log_user("** No gpus requested! Please use eristwo/slurm for cpu jobs.**")
             slurm.log_info("** No gpus requested! Please use eristwo/slurm for cpu jobs. **")
             return ESLURM_INVALID_GRES
           else
             local numgpu = string.match(job_desc.tres_per_job, ":%d+$")
             -- replace ":" with ""
             numgpu = numgpu:gsub(':', '')
             if ( tonumber(numgpu) == 0) then      
               -- terminate job
               slurm.log_user("** No gpus requested! Please use eristwo/slurm for cpu jobs.**")
               slurm.log_info("** No gpus requested! Please use eristwo/slurm for cpu jobs. **")                        
               return ESLURM_INVALID_GRES
             end
        end

    end

    slurm.log_info("%s: for user %u, setting partition(s): %s.", log_prefix, submit_uid, job_desc.partition)
    slurm.log_user("Job \"%s\" queued to partition(s): %s.", job_desc.name, job_desc.partition)

    return slurm.SUCCESS
end

function slurm_job_modify(job_desc, job_rec, part_list, modify_uid)
    return slurm.SUCCESS
end

slurm.log_info("initialized")

