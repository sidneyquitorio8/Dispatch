require 'digest/md5'
module JobsHelper

	def is_available?(runner)
		runner.available == true
	end

	def responded?(job)
		Response.where(job_id: job.id).pluck(:runner_id).include?(current_runner.id)
	end

	def on_it?(job)
		Response.where(job_id: job.id).pluck(:on_it_at).any?
	end

	def est_time_comp(job)
		assigned = Response.where(job_id: job.id).where("responses.assigned_at IS NOT NULL").last
		est_completed_at = job.assigned_at + assigned.est_time.minutes
		est_completed_at.strftime('%l:%M %p %b %d')
	end

	def assigned?(job)
		Response.where(job_id: job.id).where("responses.assigned_at IS NOT NULL").any?
  end

  def completed?(job)
      if job.completed_at
        true
      else
        false
      end
  end

  def cancelled?(job)
      if job.cancelled_at
        true
      else
        false
      end
  end

	def status_class(job)
		case job.status
		when 'completed' then 'success'
		when 'unassigned' then 'alert'
		when 'cancelled' then 'alert'
		when 'assigned' then ''
		end
	end

end