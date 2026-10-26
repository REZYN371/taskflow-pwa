import type { Priority, ScheduleItem, Task } from './types';
export function calculatePriority(task: Pick<Task,'due'|'duration'|'difficulty'|'importance'|'impact'|'status'>, now = new Date()): {priority:Priority; score:number; reason:string} {
  if (task.status === 'Selesai') return {priority:'Rendah',score:0,reason:'Tugas sudah selesai.'};
  const due = new Date(`${task.due}T23:59:00`);
  const days = Math.ceil((due.getTime()-now.getTime())/86400000);
  const urgency = days < 0 ? 45 : days === 0 ? 42 : days === 1 ? 34 : days <= 3 ? 24 : days <= 7 ? 14 : 5;
  const score = urgency + task.importance*5 + task.impact*4 + task.difficulty*2 + Math.min(task.duration/30,8);
  const priority:Priority = score >= 78 ? 'Kritis' : score >= 60 ? 'Tinggi' : score >= 39 ? 'Sedang' : 'Rendah';
  let reason = days < 0 ? 'Deadline sudah lewat; segera evaluasi rencana.' : days === 0 ? 'Deadline hari ini.' : days === 1 ? 'Deadline besok.' : `Deadline sekitar ${days} hari lagi.`;
  if(task.duration >= 120) reason += ' Durasi cukup panjang, sebaiknya mulai lebih awal.';
  if(task.impact >= 4) reason += ' Dampak keterlambatan tinggi.';
  return {priority,score,reason};
}
const toMinutes=(time:string)=>{const [h,m]=time.split(':').map(Number);return h*60+m};
export function findFreeSlots(day:number, duration:number, schedule:ScheduleItem[], preferredStart='16:00', preferredEnd='22:00') {
  const busy=schedule.filter(s=>s.day===day).map(s=>({start:toMinutes(s.start),end:toMinutes(s.end)})).sort((a,b)=>a.start-b.start);
  const start=toMinutes(preferredStart), end=toMinutes(preferredEnd); const slots:{start:string;end:string;minutes:number}[]=[]; let cursor=start;
  for(const block of busy){if(block.end<=start||block.start>=end)continue; if(block.start-cursor>=duration)slots.push({start:format(cursor),end:format(block.start),minutes:block.start-cursor});cursor=Math.max(cursor,block.end);}
  if(end-cursor>=duration)slots.push({start:format(cursor),end:format(cursor+duration),minutes:end-cursor});
  return slots;
}
function format(m:number){return `${String(Math.floor(m/60)).padStart(2,'0')}:${String(m%60).padStart(2,'0')}`}
export function recommendTasks(tasks:Task[], now=new Date()){return tasks.filter(t=>t.status!=='Selesai').map(t=>({...t,...calculatePriority(t,now)})).sort((a,b)=>b.score-a.score).slice(0,3)}
